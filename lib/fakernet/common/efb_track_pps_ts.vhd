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

use work.fnet_util_pkg.all;

-- Timestamp counter principle:
--
-- The increment of the tracking value is fractional:
--
-- - Each cycle a fixed (nominal) value (ni) is added to the tracking
--   value (tv).
--
-- - A fractional counter (fv) (with n = frac_bits) is also
--   incremented, with a fixed (nominal - 2^(m-1)) value (nf) and an
--   adjustable value (fi) (with m = frac_add_bits) bits.
--
-- - Every time the fractional counter wraps, the overflow is added
--   to the tracking value (on the following cycle).
--
-- We thus have (in C notation):
--
-- tv[i+1]    = tv[i] + ni + carry[i],
--
-- fv_tmp     = fv[i] + nf + fi
--
-- fv[i+1]    = (fv_tmp % 2^n)
-- carry[i+1] = (fv_tmp / 2^n)
--
-- The total range of possible addition to the tracking value is thus:
--
-- ni + [nf, nf + 2^m - 1] / 2^n.
--
-- When the nominal add value has a fraction such that the range
-- straddles an integer, then ni is chosen as the rounded-down
-- integer.  The overflow of the fractional counter therefore can
-- carry two bits of overflow.
--
-- The tracking job is thus to adjust the value fi:
--
-- Each PPS signal (with an associated reference value (rv)) tells
-- what the current tracking value should be.  Our goal is to adjust
-- the internal increment of the value such that the tracking value
-- matches the reference on following PPS signals.
--
-- On each PPS signal, it is easy to calculate how much too much or
-- too little has been added to the tracking value, the difference dv:
--
-- dv = rv - tv
--
-- Two (complementary) methods are used for the fi adjustment:
--
-- - Frequency correction (long-term).
--
--   This tries to adjust a long-term used component of the fractional
--   increment value as fa.  This value is applied until updated by
--   some future PPS pulse.
--
-- - Phase correction (short term).
--
--   This tries to remove the phase offset measured at the PPS by
--   using an additional fractional increment value fc.
--
--   This correction is only applied until the approximate time of the
--   next PPS signal, either the next PPS signal is received or not.
--
-- Thus the total fraction increment is:
--
-- fi = fa + fc
--
-- On each PPS signal, the (apparent) necessary correction to fi can
-- be calculated from the measured tracking difference as
--
-- di = dv * 2^n / N,
--
-- i.e. how much more or less should be added to the fractional
-- counter for the next N clock cycles, such that the difference
-- becomes 0, under the assumption that the frequency of the local
-- clock would be the same until the next expected PPS pulse as it was
-- since the previous.  N is the (nominal) number of clock cycles
-- between PPS pulses.
--
-- In order to not overdo the frequency adjustment, only half of the
-- correction calculated is applied (added) to fa.
--
-- The other half is used as phase correction (fc).
--
-- Tests with other factors for the fa and fc corrections:
--
-- fa   fc   Note:
-- 1/2  1/2  Used strategy.
-- 1/2  1    Faster locking, but often fails to start lock.
-- 1/2  1/4  Too slow slewing, oscillations around good value.
-- 1/4  1/2  Similar.
--
-- Third and fourth does not do the full phase correction, which could
-- make sense if one assumes that the measurement also might be
-- somewhat jittering.  Not good in practice.
--
-- Nominal values:
--
-- M = value increase per PPS pulse
-- N = clock cycles per PPS pulse
--
-- M = N * nv = N * (ni + (nf + 2^(m-1)) / 2^n)
--
-- The locking range (how many ppm off the local clock can be, and
-- still allow tracking) is given by
--
-- 2^(m-1) / (ni * 2^n + (nf + 2^(m-1))),
--
-- where the last term 2^(m-1) typically can be ignored.  Gives:
--
-- 2^(m-1) / (ni * 2^n + nf) = clk_freq_rel_off
--
-- m = log (clk_freq_rel_off * nv * 2^n) / log(2) + 1
--
-- A reasonable value for n is given by the need for the factor between
-- di and dv to be at least 4, i.e.
--
-- 2^n / N > 4
--
-- n > log(4 * N) / log(2)
--
-- Some numerical example:
--
-- ------------------------------------------------------------------
-- 1 Hz PPS:
-- NTP timescale:                                    M = 2^32
-- 100 MHz local clock:                              N = 100000000
-- Allow 1000 ppm error:                          cfro = 0.001
--
-- nv = M / N =                                         42.949672960
-- n > log(4 * N) / log(2) = 28.5                 ;  n = 30
-- m > log(cfro * nv * 2^n) / log(2) + 1 = 26.4   ;  m = 28
-- di / dv = 2^n / N = 10.737                     ;      10
-- ni = floor ( nv - 2^(m-1) / 2^n)     [42.824]  ; ni = 42
-- nf = floor ((nv - ni) * 2^n - 2^(m-1))                885485848
--
-- Check: ni + (nf + 2^(m-1)) / 2^n =                   42.949672960
-- ------------------------------------------------------------------
-- 1 Hz PPS:
-- NTP timescale:                                    M = 2^32
-- 125 MHz local clock:                              N = 125000000
-- Allow 1000 ppm error:                          cfro = 0.001
--
-- nv                                                   34.359738368
--                                                ;  n = 30 ; m = 28
-- di / dv = 8.58                                 ;      8
--                                                ; ni = 34
--                                                       252048403
--
-- Check:                                               34.359738367
-- ------------------------------------------------------------------

entity efb_track_pps_ts is
  generic (
    frac_bits     : integer;
    frac_add_bits : integer;
    diff_limit    : integer;
    max_diff_bits : integer;
    pps_nsubsamples  : integer;
    pps_subtime_bits : integer;
    pps_subtime_mul  : integer;
    pps_subtime_div  : integer;
    qerr_mul      : integer
    );
  port (
    clk          : in  std_logic; -- Clock from board
    -- Input signals.
    i_ref_value  : in  std_logic_vector;
    i_has_value  : in  std_logic;
    i_pps        : in  std_logic; -- Clean leading-edge detector outside.
    -- PPS subsample time.
    i_pps_subtime : in  std_logic_vector(pps_subtime_bits-1 downto 0) :=
      (others => '0');
    -- Quantisation error of PPS signal.
    i_pps_qerr   : in  std_logic_vector(15 downto 0) := (others => '0');
    i_has_qerr   : in  std_logic := '0';
    -- Typically constants (can be changed, to e.g. handle dynamic 10 PPS):
    -- Added whole bits per clock cycle (always added!)
    i_nom_add_value     : in  std_logic_vector;
    -- Added fractional bits per clock cycle.
    -- Minimum, maximum is is 2^frac_bits larger.
    i_nom_add_frac_min  : in  std_logic_vector;
    -- Correction factor (from PPS offset to needed (actual) add_frac).
    i_corr_factor       : in  std_logic_vector;
    -- Nominal number of clock cycles for half a PPS cycle.
    -- (Need not be very accurate, used to disable sync after several
    -- missing PPS, and to disable phase-adjust correction in case of
    -- missing PPS.)  (Latter: TODO!)
    i_nom_pps_clks : in  std_logic_vector;
    -- Output signals.
    o_cur_value  : out std_logic_vector;
    o_sync       : out std_logic := '0';
    -- Monitoring
    o_frac_add   : out std_logic_vector(frac_add_bits-1 downto 0);
    o_diff       : out std_logic_vector(frac_add_bits-1 downto 0);
    o_diff_accum : out std_logic_vector(max_diff_bits+2-1 downto 0);
    o_frac_corr_full : out std_logic_vector(6+frac_add_bits+1-1 downto 0);
    o_quant_err   : out std_logic_vector(15 downto 0);
    o_pps_subtime : out std_logic_vector(7 downto 0);
    o_track_update : out std_logic := '0'
    );

end efb_track_pps_ts;

architecture RTL of efb_track_pps_ts is

  -- Number of bits in the tracking value.
  constant value_bits : integer := i_ref_value'length;
  -- Number of bits in the PPS-present monitor.
  constant clk_cnt_bits : integer := i_nom_pps_clks'length + 1;

  -- A reference value is pending (has been updated since last PPS).
  signal ref_value_pending : std_logic := '0';

  -- A PPS quantisation error info is pending.
  signal qerr_pending : std_logic := '0';

  -- The current value.
  signal value : unsigned(value_bits-1 downto 0) := (others => '0');
  -- Update of current value.
  signal value_next : unsigned(value_bits-1 downto 0) := (others => '0');

  -- Pipelined pps sub-cycle time.
  signal pps_subtime_p0 : std_logic_vector(i_pps_subtime'range) :=
    (others => '0');
  -- Latched (and held) value (useful for debugging).
  signal debug_pps_subtime : std_logic_vector(i_pps_subtime'range) :=
    (others => '0');
  -- Additional difference due to the actual sub-clock arrival of the PPS
  -- signal.
  signal diff_by_pps_subtime : unsigned(5 downto 0) := (others => '0');
  signal debug_diff_by_pps_subtime : unsigned(5 downto 0) := (others => '0');

  signal diff_by_pps_qerr : signed(9+10-1 downto 0) := (others => '0');

  constant pps_subtime_to_ntp : frac_int_array(0 to pps_nsubsamples-1) :=
    frac_int_vector(pps_nsubsamples, pps_subtime_mul, pps_subtime_div);
  -- From 0 to 34.359 (2^32 / 125000000):
  -- (0,  2,  4,  6,  8,  10, 12, 15, 17, 19, 21, 23, 25, 27, 30, 32)

  -- Difference between (input) reference value and current value.
  -- (Only used cycle after PPS.)
  signal diff_value : signed(value_bits-1 downto 0) := (others => '0');
  -- Pipeline calculations.
  signal diff_value_p0 : signed(value_bits-1 downto 0) := (others => '0');
  signal diff_value_p1 : signed(value_bits-1 downto 0) := (others => '0');
  -- Latched (and held) diff value (useful for debugging).
  signal debug_diff_value : signed(value_bits-1 downto 0) := (others => '0');

  -- Absolute value of diff value (contribution to running average).
  signal abs_diff_value : signed(max_diff_bits-1 downto 0) := (others => '0');
  -- Running average of the diff value.
  signal debug_diff_accum : unsigned(max_diff_bits+2-1 downto 0) :=
    (others => '1');

  -- Is the difference within tracking tolerance.
  signal diff_within_range : std_logic := '0';

  -- Clk counter (PPS-present monitor).
  signal clk_cnt : unsigned(clk_cnt_bits-1 downto 0) := (others => '0');
  signal clk_cnt_next : unsigned(clk_cnt_bits downto 0) := (others => '0');
  -- Reset the monitor.
  signal reset_clk_cnt : std_logic := '0';

  -- Fractional value.
  signal frac : unsigned(frac_bits-1 downto 0) := (others => '0');
  -- Update of fractional value (with carry).
  signal frac_next : unsigned(frac_bits+2-1 downto 0) := (others => '0');

  -- Proposed update (all bits produced by multiplier).
  signal frac_corr_full : signed(i_corr_factor'length +
                                 frac_add_bits+1-1 downto 0) := (others =>'0');
  -- Latched (and held) proposed update (useful for debugging).
  signal debug_frac_corr_full : signed(frac_corr_full'range) := (others =>'0');
  -- Phase (short-term) correction of the fractional value.
  signal frac_corr :   signed(frac_add_bits-1 downto 0) := (others => '0');

  -- Stop doing phase adjustment.
  signal force_new_frac_both : std_logic := '0';

  -- Frequency (long-term) correction of the fractional value.
  signal frac_add  : unsigned(frac_add_bits-1 downto 0) := (others => '0');
  -- Proposed update.
  signal frac_add_next : signed(frac_add_bits downto 0) := (others => '0');

  -- Combined correction value of frequency and phase correction.
  signal frac_both : unsigned(frac_add_bits-1 downto 0) := (others => '0');
  -- Value to consider for update.
  signal frac_both_next : unsigned(frac_add_bits+1-1 downto 0) :=
    (others => '0');

  -- Carry from fractional counter.  Must have two carry bits, since
  -- i_nom_add_frac_min + frac_both can be > frac, and thus give
  -- two bits of increment.
  signal frac_carry_out : unsigned(1 downto 0) := "00";

  -- Delayed handling (pipeline), 1-6 cycles after PPS signal.
  signal init_value_delay1 : std_logic := '0';
  signal check_pps_delay1 : std_logic := '0';
  signal check_pps_delay2 : std_logic := '0';
  signal check_pps_delay3 : std_logic := '0';
  signal check_pps_delay4 : std_logic := '0';
  signal check_pps_delay5 : std_logic := '0';
  signal check_pps_delay6 : std_logic := '0';

  -- Made an update (for debug).
  signal track_update : std_logic := '0';

  -- Is tracking synchronised to PPS signals.
  signal synced     : std_logic := '0';
  signal try_sync   : unsigned(2 downto 0) := "000";

begin

  -- Next value.
  value_next <= value + unsigned(i_nom_add_value) + frac_carry_out;

  clk_cnt_next <= ("0" & clk_cnt) - 1;

  -- We add both the long-term (frequency) correction (frac_add) and
  -- the short-term (phase) correction (frac_corr).
  frac_both_next <= unsigned(signed("0" & frac_add) + frac_corr);
  -- frac_both_next <=
  --   unsigned(signed("0" & frac_add) + frac_corr(frac_corr'left downto 1));
  -- frac_both_next <= unsigned(signed("0" & frac_add));

  -- Next fractional value.
  frac_next <=
    ("00" & frac) + unsigned(i_nom_add_frac_min) + frac_both;

  -- How large is the distance to the next expected value?
  -- We want the negative offset, i.e. how much to correct.
  diff_value <= signed(i_ref_value) - signed(value) +
                signed("0" & diff_by_pps_subtime) -
                diff_by_pps_qerr(9+10-1 downto 8);

  -- Multiplication (expensive):
  frac_corr_full <=
    diff_value_p1(frac_add_bits-1 downto 0) * signed("0" & i_corr_factor);
  -- Addition.
  frac_add_next <= signed("0" & frac_add) + frac_corr;
  -- frac_add_next <= signed("0" & frac_add) + frac_corr(frac_corr'left downto 1);

  -- Is the difference within tracking limits?
  diff_within_range <=
    '1' when (diff_value_p1 <  to_signed( diff_limit,
                                         diff_value_p1'length) and
              diff_value_p1 >= to_signed(-diff_limit,
                                         diff_value_p1'length)) else '0';

  process (clk)
  begin
    if (rising_edge(clk)) then

      -- Update value (may be reset below).
      value      <= value_next;

      clk_cnt   <= clk_cnt_next(clk_cnt'range);

      -- Update fractional counter
      frac           <= frac_next(frac'range);
      frac_carry_out <= frac_next(frac_next'high downto frac_next'high-1);

      -- Delayed (pipeline) latching of values.
      init_value_delay1 <= '0';
      check_pps_delay1 <= '0';
      check_pps_delay2 <= check_pps_delay1;
      check_pps_delay3 <= check_pps_delay2;
      check_pps_delay4 <= check_pps_delay3;
      check_pps_delay5 <= '0';
      check_pps_delay6 <= check_pps_delay5;

      force_new_frac_both <= '0';
      reset_clk_cnt <= '0';

      -- Wrap of the monitor counter.  Happens ~ once per PPS pulse,
      -- in-between expected pulses (to not have race against expected
      -- location).
      if (clk_cnt_next(clk_cnt_next'high) = '1') then
        -- Wrapped, reset.
        clk_cnt <= unsigned("0" & i_nom_pps_clks);

        -- Either the PPS will come very soon, or we just missed it.
        -- Disable the phase-adjustment, such that we do not drift a
        -- lot in case it was just one missing pulse.
        frac_corr <= (others => '0');
        force_new_frac_both <= '1'; -- Force use of new frac_corr value.

        -- Missed a PPS signal.  Decrease the sync status.
        if (try_sync = "000") then
          synced <= '0';
        else
          try_sync <= try_sync - 1;
        end if;
      end if;

      if (reset_clk_cnt = '1') then
        -- Reset the (monitor) clk counter.
        -- First count is with 1.5 period, such that missing PPS are
        -- done at half-expected period.
        clk_cnt <= unsigned("0" & i_nom_pps_clks) +
                   unsigned(i_nom_pps_clks(i_nom_pps_clks'left downto 1));
      end if;

      if (i_has_value = '1') then
        ref_value_pending <= '1';
      elsif (i_pps = '1') then
        -- This also ensures that a rapid stream of bogus PPS signals
        -- do not yank us out of sync immediately, since the code
        -- below will only happen for the first one PPS signal after a
        -- time message.
        ref_value_pending <= '0';
      end if;

      if (i_has_qerr = '1') then
        qerr_pending <= '1';
      elsif (i_pps = '1') then
        qerr_pending <= '0';
      end if;

      if (i_pps = '1' and ref_value_pending = '1') then
        -- If we are not synced, and not yet attempting,
        -- but have a valid reference value, then set the value.
        if (synced = '0' and
            try_sync = "000") then
          init_value_delay1 <= '1';
          try_sync <= "001";

          -- The difference at this PPS is perfect.
          -- previous_diff <= (others => '0');
        else
          -- Since adding happens one cycle later, the check
          -- for all later PPS pulses is delayed one cycle.
          check_pps_delay1 <= '1';
        end if;

        -- Only reset the monitor counter if we are not in sync,
        -- or if the PPS signal was deemed good (further down).
        --
        -- We reset the counter, such that the monitor does not kill
        -- the phase correction when doing initial locking.
        if (synced = '0') then
          reset_clk_cnt <= '1';
        end if;
      end if;

      if (init_value_delay1 = '1') then
        -- Restart counting at the reference value
        value <= unsigned(i_ref_value);
      end if;
      -- Analogous to start, perfect counting reaches the next
      -- reference value at the check_pps_delay1 cycle.
      pps_subtime_p0 <= i_pps_subtime;

      -- Look up the difference due to the PPS fine time,
      -- effectively at the check_pps_delay1 cycle.
      diff_by_pps_subtime <=
        to_unsigned(pps_subtime_to_ntp(to_integer(unsigned(pps_subtime_p0))),
                    diff_by_pps_subtime'length);

      -- The quantization error is delivered in ps.  We pick from bit
      -- 7, so in units of 128 ps quantisation error.  We will use
      -- from bit 8 of the product, i.e. another multiplier of 256.
      -- 128 * 1e-12 * 2^32 * 256 = 140.7
      diff_by_pps_qerr <=
        signed(i_pps_qerr(15 downto 7)) * to_signed(qerr_mul,10);

      if (check_pps_delay1 = '1') then
        debug_pps_subtime <= pps_subtime_p0;
      end if;

      if (check_pps_delay2 = '1') then
        debug_diff_by_pps_subtime <= diff_by_pps_subtime;
        -- Latch the diff value, to pipeline calculations.
        diff_value_p0 <= diff_value;
      end if;

      -- Additional pipeline stage for multiplication.  Outside
      -- if-statement such that toolchain can infer pipeline register.
      -- (During check_pps_delay3.)
      diff_value_p1 <= diff_value_p0;
      if (check_pps_delay3 = '1') then
        -- Do not do the debug latch on the original value, as that is
        -- just at the calculation.  (Avoid fan-out.)
        debug_diff_value <= diff_value_p0;
      end if;

      if (check_pps_delay4 = '1') then
        -- We had i_pps and i_has_value prev-previous cycle,
        -- and were not completely out-of-sync.

        if (diff_within_range = '1') then
          if (try_sync = "111") then
            synced <= '1';
          else
            try_sync <= try_sync + 1;
          end if;
        else
          -- The main handling to decrease try_sync is done in the
          -- missing pps monitor.  We only handle the case when we are
          -- not yet synced and get spurious PPS signals.  This is
          -- needed such that a bad start get back to try_sync = 000
          -- to then reinit the tracking value completely.
          if (synced = '0') then
            if (try_sync /= "000") then
              try_sync <= try_sync - 1;
            end if;
          end if;
        end if;

        if (diff_within_range = '1') then
          -- PPS signal was within bounds.  Reset the monitor.
          reset_clk_cnt <= '1';
        end if;

        -- Since last cycle, how much too much or little have
        -- we added?

        -- Latched the diff value multiplied by the precalculated
        -- factor to give the fractional add correction.

        --frac_corr <= frac_corr_full(2*frac_add_bits-1 downto frac_add_bits);
        -- Divide by 2, do only half the correction.
        frac_corr <=
          frac_corr_full(frac_corr_full'left) &
          frac_corr_full(frac_add_bits-1 downto 1);
        -- frac_corr <= frac_corr_full(frac_add_bits-1 downto 0);

        debug_frac_corr_full <= frac_corr_full;
        -- Evaluate abs value.
        if (diff_within_range = '1') then
          abs_diff_value <= abs(diff_value_p1(abs_diff_value'range));
        else
          abs_diff_value <= to_signed(diff_limit,abs_diff_value'length);
        end if;

        -- We only do the update stages below if the difference was
        -- within range.  Otherwise most likely a spurious PPS signal.
        -- If we are not yet synced, then the updates are needed.
        if (diff_within_range = '1' or
            synced = '0') then
          check_pps_delay5 <= '1';
        end if;
      end if;

      if (check_pps_delay5 = '1') then
        -- Does the suggested adjustment value overflow the range?
        if (frac_add_next(frac_add_next'left) = '1') then
          -- Flush to zero or max value, depending on under- or overflow.
          frac_add <= (others => frac_add(frac_add'left));
        else
          -- Within limits.
          frac_add <= unsigned(frac_add_next(frac_add'range));
        end if;
        -- Accumulate the difference, with decaying average.
        -- 3/4 of old value, and add new.
        debug_diff_accum <=
          ("0"  & debug_diff_accum(debug_diff_accum'left downto 1)) +
          ("00" & debug_diff_accum(debug_diff_accum'left downto 2)) +
          ("00" & unsigned(abs_diff_value));
      end if;

      if (check_pps_delay6 = '1' or
          force_new_frac_both = '1') then
        -- Is the sum of frac_add and frac_corr within limits?
        if (frac_both_next(frac_both_next'left) = '1') then
          -- Flush to zero or max value, depending on under- or
          -- overflow of the new proposed value.
          frac_both <=
            (others => frac_both_next(frac_both_next'left));
        else
          -- Within limits.
          frac_both <= unsigned(frac_both_next(frac_both'range));
        end if;
      end if;

      -- There was a tracking update if we came the normal path.
      track_update <= check_pps_delay6;

    end if;

  end process;

  o_cur_value  <= std_logic_vector(value);
  o_frac_add   <= std_logic_vector(frac_add);
  o_sync       <= synced;
  o_diff       <= std_logic_vector(debug_diff_value(o_diff'range));
  o_diff_accum <= std_logic_vector(debug_diff_accum);
  o_frac_corr_full(debug_frac_corr_full'range) <=
    std_logic_vector(debug_frac_corr_full);
  --o_quant_err   <= i_pps_qerr;
  --o_pps_subtime <= debug_pps_subtime;
  o_quant_err <= "00000" & std_logic_vector(diff_by_pps_qerr(9+10-1 downto 8));
  o_pps_subtime <= "00" & std_logic_vector(debug_diff_by_pps_subtime);
  o_track_update <= track_update;

end RTL;
