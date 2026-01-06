-- Copyright (c) 2022, Haakan T. Johansson
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the authors nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; -- GET RID OF THIS!

use work.fnet_records.all; -- For word32_array.
use work.fnet_util_pkg.all; -- For fnet_or_reduction.

entity efb_pmod_gps is
  generic (clk_freq   : integer;
           pps_nsubsamples : integer := 0);
  port (
    clk               : in  std_logic; -- Clock from board
    -- Input signals.
    pin_rx            : in  std_logic;
    pin_3dfix         : in  std_logic;
    -- Output signals.
    pin_tx            : out std_logic := 'Z';

    -- From sub-clock sampler of pps signal.
    pps_subsamples    : in  std_logic_vector(pps_nsubsamples+2-1 downto 0) :=
                              (others => '0');

    -- From PPS leading-edge detector.
    o_pps_pulse       : out std_logic := '0';

    -- (Raw) output from the UART receiver.
    o_uart_rx_byte    : out std_logic_vector (7 downto 0) := (others => '0');
    o_uart_has_data   : out std_logic := '0';

    -- Output from the NMEA decoder.
    o_nmea_seconds    : out std_logic_vector(16 downto 0);
    o_nmea_days       : out std_logic_vector(15 downto 0);
    o_nmea_valid_fix  : out std_logic;
    o_nmea_has_t_data : out std_logic;

    -- Seconds on next PPS (calculated from NMEA).
    o_seconds_next    : out std_logic_vector(31 downto 0);
    o_seconds_next_set : out std_logic;

    -- From the NTP timescale tracker.
    o_ntp_leap        : out std_logic_vector(1 downto 0) := "11";
    o_ntp_prec        : out std_logic_vector(7 downto 0) := (others => '1');
    o_ntp_root_disp   : out std_logic_vector(31 downto 0) := (others => '1');
    o_ntp_cur_ts      : out std_logic_vector(63 downto 0) := (others => '0');
    o_ntp_ref_ts      : out std_logic_vector(63 downto 0) := (others => '0');

    -- Additional (debug) from the NTP tracker.
    o_ntp_track_sync  : out std_logic := '0';
    o_ntp_frac_add    : out std_logic_vector(27 downto 0);
    o_ntp_track_diff  : out std_logic_vector(27 downto 0);
    o_ntp_track_update : out std_logic := '0';
    o_ntp_track_frac_corr_full : out std_logic_vector(6+28+1-1 downto 0);

    -- Monitor data stream.
    i_mon_cycle_count : in  std_logic_vector(31 downto 0);
    i_mon_gps_no      : in  integer;
    o_mon_data_array  : out word32_array(0 to 13) := (others => (others=>'0'));
    o_mon_has_data    : out std_logic_vector(0 to 13) := (others => '0');
    i_mon_data_pending : in std_logic_vector(0 to 13)
    );

end efb_pmod_gps;

architecture RTL of efb_pmod_gps is

  -- Invert input signal.
  signal not_rx           : std_logic := '0';

  constant pps_subtime_bits : integer := fnet_log2(pps_nsubsamples-1)+1;

  -- PPS signal subsampling.
  signal pps_subsample_transition :
    std_logic_vector(pps_nsubsamples-1 downto 0) := (others => '0');
  signal pps_subsample_mask :
    std_logic_vector(pps_nsubsamples downto 0) := (others => '0');
  signal pps_subsample_time_tmp :
    std_logic_vector(pps_subtime_bits-1 downto 0) := (others => '0');
  signal pps_subsample_time     :
    std_logic_vector(pps_subtime_bits-1 downto 0) := (others => '0');
  signal pps_subsample_time_p1  :
    std_logic_vector(pps_subtime_bits-1 downto 0) := (others => '0');

  -- Is a transition seen in any of the subsamples?
  signal pps_transition   : std_logic := '0';

  -- Filtered PPS leading edge.
  signal pps_pulse        : std_logic := '0';

  -- For PPS monitor.
  signal pps_pulse_dly    : std_logic := '0'; -- Delay for monitor write.
  signal last_pps_at      : std_logic_vector(31 downto 0) := (others => '0');
  signal last_pps_subsample_at :
    std_logic_vector(pps_subtime_bits-1 downto 0) := (others => '0');
  signal last_pps_subsample_at_extend : -- Extend with low bits (fractional).
    std_logic_vector(7 downto pps_subtime_bits) := (others => '0');
  signal pps_count        : unsigned(3 downto 0)  := (others => '0');

  -- From UART.
  signal uart_rx_byte     : std_logic_vector (7 downto 0) := (others => '0');
  signal uart_has_data    : std_logic := '0';

  -- For UART monitor.
  signal uart_rx_byte_count : unsigned(3 downto 0) := (others => '0');

  -- From NMEA.
  signal nmea_seconds     : std_logic_vector(16 downto 0);
  signal nmea_days        : std_logic_vector(15 downto 0);
  signal nmea_valid_fix   : std_logic;
  signal nmea_has_t_data  : std_logic;

  -- Seconds on next PPS signal (from NMEA + 1).
  signal seconds_next     : std_logic_vector(31 downto 0);
  signal seconds_next_set : std_logic := '0'; -- On cycle when assigned.
  signal seconds_pending  : std_logic := '0';

  signal ntp_next_ts      : std_logic_vector(63 downto 0) := (others => '0');

  -- From UBLOX.
  signal ubx_qerr         : std_logic_vector(15 downto 0);
  signal ubx_has_qerr_data: std_logic;

  signal qerr_next        : std_logic_vector(15 downto 0);

  -- Control values for NTP tracker.
  signal nom_add_value    : std_logic_vector(5 downto 0);
  signal nom_add_frac_min : std_logic_vector(29 downto 0);
  signal corr_factor      : std_logic_vector(5 downto 0);
  signal nom_pps_clks     : std_logic_vector(26 downto 0);
  -- Info for monitoring
  signal period_ps        : std_logic_vector(15 downto 0);

  -- From NTP tracker.
  signal ntp_leap         : std_logic_vector(1 downto 0) := "11";
  signal ntp_prec         : std_logic_vector(7 downto 0) := (others => '1');
  signal ntp_root_disp    : std_logic_vector(31 downto 0) := (others => '0');
  signal ntp_cur_ts       : std_logic_vector(63 downto 0) := (others => '0');
  signal ntp_ref_ts       : std_logic_vector(63 downto 0) := (others => '0');

  signal ntp_track_sync   : std_logic := '0';
  signal ntp_frac_add     : std_logic_vector(27 downto 0);
  signal ntp_track_diff   : std_logic_vector(27 downto 0);
  signal ntp_track_diff_accum : std_logic_vector(25 downto 0);
  signal ntp_track_frac_corr_full : std_logic_vector(6+28+1-1 downto 0);
  signal ntp_track_quant_err : std_logic_vector(15 downto 0);
  signal ntp_track_pps_subtime : std_logic_vector(7 downto 0);
  signal ntp_track_update : std_logic := '0';

  signal ntp_track_upd_cnt : unsigned(3 downto 0);

  signal ntp_track_diff_accum_mask : std_logic_vector(29+1 downto 0);
  signal ntp_track_diff_accum_bits : std_logic_vector(5 downto 0);

  -- Monitor data stream.
  signal ntp_track_diff_sign_extend : std_logic_vector(31 downto 28);
  signal mon_gps_no       : std_logic_vector(3 downto 0) := (others => '0');
  signal mon_data_array   : word32_array(0 to 13) := (others => (others=>'0'));
  signal mon_has_data     : std_logic_vector(0 to 13) := (others => '0');

  -- 2^-31 ~ 0.46 ns, the best precision we will report.
  constant best_precision : integer := -31;

begin

  not_rx <= not pin_rx;

  -- UART receiver.  Contains anti-metastability for RX signal.
  uart_rx_c : entity work.efb_uart_rx
    port map(
      clk             => clk,
      i_bit_period    => std_logic_vector(to_unsigned(clk_freq / 9600, 16)),
      i_rx            => not_rx,
      --
      o_data          => uart_rx_byte,
      o_has_data      => uart_has_data
      );

  -- NMEA parser.  (Only gets time from $GPRMC.)
  -- Note: output data only valid with o_has_data and o_valid!
  -- (The seconds and days are latched during decoding, but not yet
  -- validated.)
  nmea_parse : entity work.efb_nmea_parse
    port map (
      clk          => clk,
      i_data       => uart_rx_byte,
      i_has_data   => uart_has_data,
      o_seconds    => nmea_seconds,
      o_days       => nmea_days,
      o_valid_fix  => nmea_valid_fix,
      o_has_t_data => nmea_has_t_data
      );

  ubx_parse : entity work.efb_ublox_parse
    port map (
      clk          => clk,
      i_data       => uart_rx_byte,
      i_has_data   => uart_has_data,
      o_qerr       => ubx_qerr,
      o_has_qerr_data => ubx_has_qerr_data
      );

  -- NTP time tracker, disciplined by PPS signal.

  -- Control values, based on the nominal board clock frequency.
  -- See efb_track_pps_ts.vhd for calculation of these values.
  tctrl100: if (clk_freq = 100000000) generate
    nom_add_value    <= std_logic_vector(to_unsigned(42,6));
    nom_add_frac_min <= std_logic_vector(to_unsigned(885485848,30));
    corr_factor      <= std_logic_vector(to_unsigned(10,6));
    period_ps        <= std_logic_vector(to_unsigned(10000,16));
  end generate;
  tctrl125: if (clk_freq = 125000000) generate
    nom_add_value    <= std_logic_vector(to_unsigned(34,6));
    nom_add_frac_min <= std_logic_vector(to_unsigned(252048403,30));
    corr_factor      <= std_logic_vector(to_unsigned(8,6));
    period_ps        <= std_logic_vector(to_unsigned(8000,16));
  end generate;
  nom_pps_clks     <= std_logic_vector(to_unsigned(clk_freq,27));

  -- It surely can happen that we detect two locations.  E.g. by a
  -- pattern 001001.  That is rectified in the mask, which ensures
  -- that all lower bits are set.
  pps_subsample_mask(pps_nsubsamples) <= '0';
  pps_subsample_001: for i in 0 to pps_nsubsamples-1 generate
    pps_subsample_transition(i) <=
      '1' when
      (pps_subsamples(i+2 downto i) = "001") else
      '0';
    pps_subsample_mask(i) <=
      pps_subsample_mask(i+1) or pps_subsample_transition(i);
  end generate;

  -- This also works without subsamples,a s long as the two extra bits
  -- contain the previous two samples.
  pps_transition <= fnet_or_reduction(pps_subsample_transition);

  -- Convert the bitstring of the PPS subsamples into a number.
  -- Since we (when interesting) always have at least one bit set,
  -- ignore that one.  (Otherwise count is 1-16, not 0-15.)
  pps_subsample_loc: entity work.efb_count_low_bits
    port map (x => pps_subsample_mask(pps_nsubsamples-1 downto 1),
              y => pps_subsample_time_tmp);

  pps_subsample_time <= pps_subsample_time_tmp;

  -- To NTP timescale format.  (Easy, low 32 bits are fractional seconds.)
  ntp_next_ts(63 downto 32) <= seconds_next;
  ntp_next_ts(31 downto  0) <= (others => '0');

  ntp_track_pps : entity work.efb_track_pps_ts
    generic map(
      frac_bits => 30,         -- n
      frac_add_bits => 28,     -- m
      diff_limit => 13421772,  -- ??
      max_diff_bits => 24,     -- ??
      pps_nsubsamples  => pps_nsubsamples,
      pps_subtime_bits => pps_subtime_bits,
      pps_subtime_mul  => 134217728,
      pps_subtime_div  => 62500000,
      qerr_mul         => 141
      )
    port map (
      clk          => clk,
      i_ref_value  => ntp_next_ts,
      i_has_value  => seconds_next_set,
      i_pps        => pps_pulse,

      i_pps_subtime => pps_subsample_time_p1,

      i_pps_qerr   => qerr_next,
      i_has_qerr   => ubx_has_qerr_data,

      i_nom_add_value    => nom_add_value,
      i_nom_add_frac_min => nom_add_frac_min,
      i_corr_factor      => corr_factor,
      i_nom_pps_clks     => nom_pps_clks,

      o_cur_value  => ntp_cur_ts,
      o_sync       => ntp_track_sync,

      o_frac_add   => ntp_frac_add,
      o_diff       => ntp_track_diff,
      o_diff_accum => ntp_track_diff_accum,
      o_frac_corr_full => ntp_track_frac_corr_full,
      o_quant_err    => ntp_track_quant_err,
      o_pps_subtime  => ntp_track_pps_subtime,
      o_track_update => ntp_track_update
      );

  -- Make mask up to the highest bit set in the running average of
  -- the measured differences (which are in NTP units).
  ntp_track_diff_accum_mask(ntp_track_diff_accum_mask'left) <= '0';
  ntdam_gen: for i in ntp_track_diff_accum'range generate
    ntp_track_diff_accum_mask(i) <=
      ntp_track_diff_accum_mask(i+1) or ntp_track_diff_accum(i);
  end generate;

  ntdam_count_bits: entity work.efb_count_low_bits
    port map (x => ntp_track_diff_accum_mask,
              y => ntp_track_diff_accum_bits);

  process(clk)
  begin
    if (rising_edge(clk)) then

      -- Default.
      seconds_next_set <= '0';

      if (nmea_has_t_data = '1' and
          nmea_valid_fix = '1') then
        -- We got a value nmea message with seconds info.
        -- Calculate the seconds on the next PPS signal.
        seconds_next <=
          nmea_seconds +
          std_logic_vector(to_unsigned((100 * 365 + 24) * 24 * 3600 + 1 +
                                       24 * 3600 *
                                       to_integer(unsigned(nmea_days)),
                                       32));
        seconds_next_set <= '1';
        -- Value is pending for use on next PPS signal.
        seconds_pending  <= '1';
      end if;

      if (ubx_has_qerr_data = '1') then
        qerr_next <= ubx_qerr;
      end if;

      -- Default, no PPS pulse.
      pps_pulse <= '0';

      -- Pipeline.
      pps_subsample_time_p1 <= pps_subsample_time;

      -- Leading edge detector for incoming PPS signal.
      if (pps_transition = '1') then
        -- Start of PPS pulse just seen.
        pps_pulse <= '1';
        -- If we had a pending seconds info from NMEA, use it to
        -- update the reference time.
        if (seconds_pending = '1') then
          ntp_ref_ts(63 downto 32) <= seconds_next;
        end if;
        -- Either we had or not - no longer pending.
        seconds_pending <= '0';
      end if;

      -- The ntp_track_diff_accum_mask value has two fractional bits, thus
      -- if the lowest bit is set, we have a precision of ~ 2^-34 s.
      ntp_prec <=
        std_logic_vector((to_signed(-34,8) +
                          signed(ntp_track_diff_accum_bits)));
      -- Clamp the precision reported.
      if (ntp_track_diff_accum_bits < 34+best_precision) then
        ntp_prec <= std_logic_vector(to_signed(best_precision,8));
      end if;

      -- If tracking is in sync, report valid NTP timestamp.
      if (ntp_track_sync = '1') then
        ntp_leap <= "00";
        -- Two sub-bit-32 bits, and another 16 bits are below the
        -- LSB of ntp_root_disp.
        ntp_root_disp(31 downto 25-18+1) <= (others => '0');
        ntp_root_disp(25-18 downto 0) <= ntp_track_diff_accum(25 downto 18);
      else
        ntp_leap <= "11";
        ntp_prec <= (others => '1'); -- 127
        ntp_root_disp(31 downto 25-18+1) <= (others => '1');
      end if;

      -- PPS monitor.
      if (pps_pulse = '1') then
        last_pps_at <= i_mon_cycle_count;
        last_pps_subsample_at <= pps_subsample_time_p1;
      end if;
      pps_count <= pps_count + ("" & pps_pulse);

      ntp_track_upd_cnt <= ntp_track_upd_cnt + ("" & ntp_track_update);

      -- Provide data to stream interface next cycle.
      pps_pulse_dly <= pps_pulse;

      -- UART monitorning.
      uart_rx_byte_count <= uart_rx_byte_count + ("" & uart_has_data);

    end if;
  end process;

  o_pps_pulse        <= pps_pulse;

  o_uart_rx_byte     <= uart_rx_byte;
  o_uart_has_data    <= uart_has_data;

  o_nmea_seconds     <= nmea_seconds;
  o_nmea_days        <= nmea_days;
  o_nmea_valid_fix   <= nmea_valid_fix;
  o_nmea_has_t_data  <= nmea_has_t_data;

  o_seconds_next     <= seconds_next;
  o_seconds_next_set <= seconds_next_set;

  o_ntp_leap         <= ntp_leap;
  o_ntp_prec         <= ntp_prec;
  o_ntp_root_disp    <= ntp_root_disp;
  o_ntp_cur_ts       <= ntp_cur_ts;
  o_ntp_ref_ts       <= ntp_ref_ts;

  o_ntp_track_sync   <= ntp_track_sync;
  o_ntp_frac_add     <= ntp_frac_add;
  o_ntp_track_diff   <= ntp_track_diff;
  o_ntp_track_frac_corr_full <= ntp_track_frac_corr_full;
  o_ntp_track_update <= ntp_track_update;

  --------------------------------------------------------------------

  -- Monitoring by streaming of 32-bit data words.

  -- Sign-extend:
  ntp_track_diff_sign_extend <=
    (others => ntp_track_diff(ntp_track_diff'left));

  mon_gps_no <= std_logic_vector(to_unsigned(i_mon_gps_no,mon_gps_no'length));

  -- GPS monitor data format:  (GSP # is n)
  --
  -- 00000001 nnnn0001 ....cccc uuuuuuuu : UART byte (u) and count (c)
  --
  -- 00000001 nnnn0010 ssssssss ....cccc : PPS pps-subclk (s), count (c),
  -- tttttttt tttttttt tttttttt tttttttt   clock counter @ PPS
  -- qqqqqqqq qqqqqqqq pppppppp pppppppp   quantization err (q), period [ps](p)
  --
  -- 00000001 nnnn0011 ........ ........ :
  -- ssssssss ssssssss ssssssss ssssssss   seconds on next PPS (from NMEA)
  --
  -- 00000001 nnnn0100 PPPPPPPP cccc...S : timestamp track sync (S), precision
  -- ssssssss ssssssss ssssssss ssssssss   NTP time seconds (s)
  -- ffffffff ffffffff ffffffff ffffffff   NTP time fractional seconds (f)
  -- aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa   fractional add (a)
  -- dddddddd dddddddd dddddddd dddddddd   timestamp diff at PPS (d)
  -- rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr   running average abs diff at PPS (r)
  -- cccccccc cccccccc cccccccc cccccccc   fractional add corr (full) (c)
  -- 00000000 qqqqqqqq qqqqqqqq ssssssss   quantization err (q), pps-subclk (s)

  mon_data_array(0) <= "00000001" & mon_gps_no & "0001" & "0000" &
                       std_logic_vector(uart_rx_byte_count) & uart_rx_byte;
  mon_has_data(0) <= (uart_has_data and
                      not i_mon_data_pending(0));

  mon_data_array(1) <= "00000001" & mon_gps_no & "0010" &
                       last_pps_subsample_at & last_pps_subsample_at_extend &
                       "0000" & std_logic_vector(pps_count);
  mon_data_array(2) <= last_pps_at;
  mon_data_array(3) <= qerr_next & period_ps;
  mon_has_data(1 to 3) <= (others => (pps_pulse_dly and
                                      not i_mon_data_pending(3)));

  mon_data_array(4) <= "00000001" & mon_gps_no & "0011" & "0000000000000000";
  mon_data_array(5) <= seconds_next;
  mon_has_data(4 to 5) <= (others => (seconds_next_set and
                                      not i_mon_data_pending(5)));

  mon_data_array(6) <= "00000001" &
                       mon_gps_no & "0100" & ntp_prec &
                       std_logic_vector(ntp_track_upd_cnt) &
                       "000" & ntp_track_sync;
  mon_data_array(7) <= ntp_cur_ts(63 downto 32);
  mon_data_array(8) <= ntp_cur_ts(31 downto  0);
  mon_data_array(9) <= "0000" & ntp_frac_add;
  mon_data_array(10) <= ntp_track_diff_sign_extend & ntp_track_diff;
  mon_data_array(11) <= "000000" & ntp_track_diff_accum;
  mon_data_array(12) <= ntp_track_frac_corr_full(31 downto 0);
  mon_data_array(13) <= "00000000" & ntp_track_quant_err &
                        ntp_track_pps_subtime;
  mon_has_data(6 to 13) <= (others => (ntp_track_update and
                                       not i_mon_data_pending(13)));

  o_mon_data_array <= mon_data_array;
  o_mon_has_data   <= mon_has_data;

end RTL;
