-- Copyright (c) 2020, Anders Furufors
-- Copyright (c) 2020, Haakan T. Johansson
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
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.fnet_records.all; -- For word32_array.
use work.fnet_util_pkg.all; -- For fnet_if_true.

entity fakernet_top is
  generic (compiletime : integer := 1;
           dynamic_gen : integer := 1;
           use_pmod_gps : boolean := true);
  port (
        --countdebug          : out unsigned(7 downto 0);
        statedebug          : out std_logic_vector(19 downto 0) := (others => '0');
    
    clk_in      : in  std_logic;
    clk125_in      : in  std_logic;
    clk25_in      : in  std_logic;

    -- Ethernet PHY:
    
    eth_intb        : in std_logic;
    -- Control channel.
    mdio_i_debug: out std_logic := '0';
    mdio_o_debug: out std_logic := '0';
    eth_mdc        : out std_logic := '0';
    eth_mdio_in       : in std_logic;
    eth_mdio_out       : out std_logic := '0';
    eth_rstn       : out std_logic := '1';
    -- TX channel.
    eth_txd        : out std_logic_vector(7 downto 0) := (others => '0');
    eth_tx_en      : out std_logic := '0';
    eth_tx_clk     : in  std_logic;
    -- RX channel.
    eth_rxd        : in  std_logic_vector(7 downto 0);
    eth_rx_clk     : in  std_logic;
    eth_rx_dv      : in  std_logic;
    eth_rxerr      : in  std_logic;
    -- Link status.
    eth_col        : in  std_logic;
    eth_crs        : in  std_logic;
    -- Ref clk.
    eth_ref_clk    : out std_logic;

    -- SPI interface.
    spi_sdi        : in  std_logic;
    spi_csn        : inout std_logic := '1';
    spi_sdo        : inout std_logic := '1';
    --spi_wpn        : out std_logic := '1';
    --spi_hldn       : out std_logic := '1';
    --spi_sck        : inout std_logic := '1';

    -- User input.
    sw             : in  std_logic_vector(3 downto 0);
    btn            : in  std_logic_vector(3 downto 0);

    -- LEDs.
    led            : out std_logic_vector(3 downto 0);
    led_r          : out std_logic_vector(3 downto 0);
    led_g          : out std_logic_vector(3 downto 0);
    led_b          : out std_logic_vector(3 downto 0);

    -- PMOD
    ja0            : in  std_logic;
    ja1            : out std_logic;
    ja2            : in  std_logic;
    ja3            : in  std_logic;

    jd0            : in  std_logic;
    jd1            : out std_logic;

    jd2            : in  std_logic;
    jd3            : out std_logic;

    -- UART
    uart_rx        : in  std_logic;
    uart_tx        : out std_logic;
    
    user_data_word       : in std_logic_vector(31 downto 0);
    user_data_offset     : in std_logic_vector( 9 downto 0);
    user_data_write      : in std_logic;
    user_data_commit_len : in std_logic_vector( 10 downto 0);
    user_data_commit     : in std_logic;
    user_data_free       : out  std_logic;
    user_data_reset      : out  std_logic

    );

end fakernet_top;

architecture RTL of fakernet_top is

  -- Board clock frequency.
  constant clk_freq         : integer := 125000000;

  -- Clock signals.
  signal clk                : std_logic;
  signal clk25              : std_logic;
  signal clk125              : std_logic;

  -- c0a801c0 = 192.168.1.192
  signal ipaddr  : std_logic_vector(31 downto 0) :=
    "11000000" & "10101000" & "00000001" & "11000000";

  -- User switch.
  signal sw_latch       : std_logic_vector(3 downto 0) := "0000";

  -- Buffered PHY RX clock.
  signal buf_eth_rx_clk  : std_logic;

  -- Input network traffic
  signal in_word            : std_logic_vector(15 downto 0) := (others => '0');
  signal in_got_word        : std_logic := '0';
  signal in_new_packet      : std_logic := '0';
  signal in_end_packet      : std_logic := '0';

  -- Output network traffic
  signal out_word           : std_logic_vector(15 downto 0) :=
    std_logic_vector(to_unsigned(16#dead#,16));
  signal out_ena            : std_logic := '0';
  signal out_payload        : std_logic := '0';
  signal out_taken          : std_logic := '0';

  -- Buffered PHY TX clock.
  signal eth_tx_clk_buf     : std_logic;

  -- XADC

  signal xadc_data_request : std_logic := '0';
  signal xadc_data_array   : word32_array(0 to 0) :=
    (others => (others => '0'));
  signal xadc_has_data     : std_logic := '0';
  signal xadc_data_pending : std_logic := '0';

  -- SPI signals handled internally.
  signal spi_sck  : std_logic := '1';
  signal spi_wpn  : std_logic := '1';
  signal spi_hldn : std_logic := '1';

  -- Cycle counter
  signal cycle_count        : unsigned(31 downto 0) := (others => '0');

  -- PMod GPS
  constant num_pmod_gps     : integer := fnet_if_true(use_pmod_gps, 1, 0);
  constant pmod_gps_pps_nsubsampl : integer := 1;

  -- Note: RX/TX swapped w.r.t. module names, here seen from the FPGA.
  signal pmod_gps_3dfix : std_logic_vector(0 to num_pmod_gps-1); -- From GPS.
  signal pmod_gps_tx    : std_logic_vector(0 to num_pmod_gps-1); -- To GPS.
  signal pmod_gps_rx    : std_logic_vector(0 to num_pmod_gps-1); -- From GPS.
  signal pmod_gps_pps   : std_logic_vector(0 to num_pmod_gps-1); -- From GPS.
  signal pmod_gps_pps_samples : -- After sampler, 0 is most recent sample.
    std_logic_vector(num_pmod_gps * (pmod_gps_pps_nsubsampl+2) - 1 downto 0);
  signal pmod_gps_pps_samples_hist : std_logic_vector(4 downto 0);

  
  -- Sampler
  signal sample_input       : std_logic_vector(0 to 1) := (others => '0');

  signal sampler_data_array   : word32_array(0 to 3) :=
    (others => (others=>'0'));
  signal sampler_has_data     : std_logic_vector(0 to 3) :=
    (others => '0');
  signal sampler_data_pending : std_logic_vector(0 to 3) :=
    (others => '0');
  signal sampler_pulse_control : std_logic_vector(31 downto 0) :=
    (others => '0');


  -- Pulser
  signal pulser_output      : std_logic_vector(0 to 1) := (others => '0');

  signal debug : std_logic_vector(149 downto 0);
  signal mode      : std_logic;


Component ila_0 is
Port (
clk  : in std_logic;
probe0 : in std_logic_vector(199 downto 0)
);
end Component;


Component vio_0 is
Port (
clk  : in std_logic;
probe_out0 : in std_logic_vector(0 downto 0)
);
end Component;

  signal cc0      : std_logic_vector(49 downto 0) := (others => '0');
  signal cc1      : std_logic_vector(49 downto 0) := (others => '0');
  signal cc2      : std_logic_vector(49 downto 0) := (others => '0');
  signal cc3      : std_logic_vector(49 downto 0) := (others => '0');
  signal cc4      : std_logic_vector(49 downto 0) := (others => '0');
  
  signal reset_user : std_logic := '0';
  
  signal trace_signals  : std_logic_vector(31 downto 0) := (others => '0');
  signal trace_insert   : std_logic := '0';
  signal trace_trigger  : std_logic := '0';

  signal trace_tx_data     : std_logic_vector(7 downto 0) := (others => '0');
  signal trace_tx_has_data : std_logic := '0';
  
  signal uart_tx_data      : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_tx_has_data  : std_logic := '0';
  signal uart_tx_taken     : std_logic := '0';
  signal uart_tx_temp      : std_logic := '0';
  
  signal spy_tx_en          : std_logic;
  signal spy_txd            : std_logic_vector(7 downto 0);
  
begin

  -----------------------
  -- Clock generation. --
  -----------------------

    clk <= clk_in;
    clk25 <= clk25_in;
    clk125 <= clk125_in;

  -- Assign the two low bits of the IP address from user input switches.
  ipaddr(1 downto 0) <= sw_latch(1 downto 0);

  -------------------
  -- Data from PHY --
  -------------------

  -- Buffer the input clock.
--  clk_bufg: bufg
--    port map (i => eth_rx_clk,
--              o => buf_eth_rx_clk);
  buf_eth_rx_clk <= eth_rx_clk;
  -- buf_eth_rx_clk <= cheat_clk;

  rx: entity work.efnet_gmii_mii_rx
    generic map(clk_freq => clk_freq)
    port map(
      clk              => clk,
      buf_eth_rx_clk   => buf_eth_rx_clk,

      eth_rx_dv        => eth_rx_dv,
      eth_rxd          => eth_rxd,

      o_mode_gmii => mode,
      i_mode_gmii      => '1', -- MII.
      i_mode_gmii_set  => '1', -- Fixed at MII.

      o_word_1         => in_word(15 downto 8),
      o_word_2         => in_word(7 downto 0),
      o_words_ready    => in_got_word,
      o_packet_start   => in_new_packet,
      o_packet_ended   => in_end_packet
      );


--ila_inst : ila_0 
--Port map(
--clk  => clk,
--probe0(0) => eth_rx_dv,
--probe0(8 downto 1) => eth_rxd,
--probe0(24 downto 9) => in_word,
--probe0(25) => in_got_word,
--probe0(26) => in_new_packet,
--probe0(27) => in_end_packet,
--probe0(28) => spy_tx_en,
--probe0(36 downto 29) => spy_txd,
--probe0(37) => out_ena,
--probe0(53 downto 38) => out_word,
--probe0(54) => out_taken,
--probe0(199 downto 55) => (others => '0')
--);



  ---------------------------------------------------------------------

  -- Note!  The spy_tx* signals are in the eth_gtx_clk clock domain!

  trace_signals(15 downto 0) <= out_word;
  trace_signals(16) <= out_ena;
  trace_signals(17) <= out_taken;
  trace_signals(23) <= spy_tx_en;         -- WRONG clock domain!
  trace_signals(31 downto 24) <= spy_txd; -- WRONG clock domain!
  trace_insert  <= '1';
  trace_trigger <= out_ena;

  --trace_signals(15 downto 0) <= in_word;
  --trace_signals(16) <= in_got_word;
  --trace_signals(17) <= in_new_packet;
  --trace_signals(23) <= buf_eth_rx_dv;
  --trace_signals(31 downto 24) <= buf_eth_rxd;  
  --trace_insert  <= in_got_word or in_new_packet or buf_eth_rx_dv;
  --trace_trigger <=                in_new_packet or buf_eth_rx_dv;

--  trace_mem : entity work.efb_uart_trace_mem
--    generic map(
--      width => 32,
--      samples => 512)
--    port map(
--      clk             => clk125,
--      i_signals       => trace_signals,
--      i_insert        => trace_insert,
--      i_trigger       => trace_trigger,
--      o_data          => trace_tx_data,
--      i_taken         => uart_tx_taken
--      );
  trace_tx_has_data <= '1';

  uart_tx_data     <= trace_tx_data;
  uart_tx_has_data <= trace_tx_has_data;

  -- The serial-USB chip is on the board, so the UART speed is not
  -- constrained by external serial cabling.
--  uart_tx_c: entity work.efb_uart_tx
--    port map(
--      clk             => clk125,
--      --                 125000000/9600   = 13020 , 100000000/9600   = 10416
--      --                 125000000/115200 =  1085 , 100000000/115200 =   868
--      --                 125000000/230400 =   542 , 100000000/230400 =   434
--      --                 125000000/460800 =   271 , 100000000/460800 =   217
--      --                 125000000/921600 =   135 , 100000000/921600 =   108
--      i_bit_period    => std_logic_vector(to_unsigned(135, 16)),
--      i_data          => uart_tx_data,
--      i_has_data      => uart_tx_has_data,
--      o_taken         => uart_tx_taken,
--      o_tx            => uart_tx_temp
--      );

  uart_tx <= not uart_tx_temp;


  -----------------
  -- Data to PHY --
  -----------------

  -- Board only does MII, so provide TX clk.
--  eth_gtx_clk_bufg: bufg
--    port map (i => eth_tx_clk,
--              o => eth_tx_clk_buf);

--  eth_tx_clk_buf <= buf_eth_rx_clk;
  eth_tx_clk_buf <= eth_tx_clk;


  -- Emit 16-bit words as nibbles, based on the PHY tx_clk.
  tx : entity work.efnet_gmii_mii_tx
    port map(
      clk             => clk,
      buf_eth_gtx_clk => eth_tx_clk_buf,

      eth_gtx_clk     => open,
      eth_tx_en       => eth_tx_en,
      eth_txd         => eth_txd,

      spy_tx_en       => spy_tx_en,
      spy_txd         => spy_txd,

      i_mode_gmii     => '1', -- MII.

      out_ena         => out_ena,
      out_word        => out_word,
      out_taken       => out_taken
      );

  ----------------------------
  -- Common board top-level --
  ----------------------------

  pmod_gps_3dfix(0) <= ja0;
  -- pmod_gps_tx(0)    <= ja1;
  pmod_gps_rx(0)    <= ja2;
  pmod_gps_pps(0)   <= ja3;

  -- When not using an actual subsampler, we still need to provide
  -- history in index 2 and 1.  And before that do anti-metastable.
--  process(clk125)
--  begin
--    if (rising_edge(clk125)) then
--      pmod_gps_pps_samples_hist <=
--        pmod_gps_pps_samples_hist(3 downto 0) & pmod_gps_pps(0);
--    end if;
--  end process;

  pmod_gps_pps_samples <= pmod_gps_pps_samples_hist(4 downto 2);

  ja1 <= pmod_gps_tx(0);

  t: entity work.efb_common_top
    generic map(compiletime  => compiletime,
                description  => "Digilent Arty A7-35T",
--                dynamic_gen  => dynamic_gen,
                num_pmod_gps => num_pmod_gps,
                clk_freq     => clk_freq)
    port map(
    --countdebug => countdebug,
        statedebug => statedebug,
    debug => debug,
      clk            => clk,
      clk25          => clk25,
      clk125          => clk125,

      -- Maximum .bit size for Arty 100: 30606304 bits = 0x3a607c.
      spi_cfg_base_addr => std_logic_vector(to_unsigned(16#3c0000#,24)),

      cfg_ipaddr     => ipaddr,

      eth_mdc        => eth_mdc,
    mdio_i_debug => mdio_i_debug,
    mdio_o_debug => mdio_o_debug,
      eth_mdio_in       => eth_mdio_in,
      eth_mdio_out       => eth_mdio_out,
      eth_rstn       => eth_rstn,
      -- eth_txd        => eth_txd,
      -- eth_tx_en      => eth_tx_en,
      -- eth_tx_clk     => eth_tx_clk,
      out_word       => out_word,
      out_ena        => out_ena,
      out_taken      => out_taken,
      -- eth_rxd        => eth_rxd,
      -- eth_rx_clk     => eth_rx_clk,
      -- eth_rx_dv      => eth_rx_dv,
      in_word        => in_word,
      in_got_word    => in_got_word,
      in_new_packet  => in_new_packet,
      -- eth_rxerr      => eth_rxerr,
      eth_col        => eth_col,
      eth_crs        => eth_crs,

      xadc_data_request => xadc_data_request,
      xadc_data_array   => xadc_data_array,
      xadc_has_data     => xadc_has_data,
      xadc_data_pending => xadc_data_pending,

      spi_sdi        => spi_sdi,
      spi_csn        => spi_csn,
      spi_sdo        => spi_sdo,
      spi_wpn        => spi_wpn,
      spi_hldn       => spi_hldn,
      spi_sck        => spi_sck,

      sw             => sw,
      btn            => btn,

      led            => led,
      led_r          => led_r,
      led_g          => led_g,
      led_b          => led_b,

      pmod_gps_3dfix => pmod_gps_3dfix,
      pmod_gps_tx    => pmod_gps_tx,
      pmod_gps_rx    => pmod_gps_rx,
      pmod_gps_pps_samples => pmod_gps_pps_samples,

      uart_rx        => uart_rx,
--      uart_tx        => uart_tx,

      sampler_data_array   => sampler_data_array,
      sampler_has_data     => sampler_has_data,
      sampler_data_pending => sampler_data_pending,
      
    user_data_word       => user_data_word,
    user_data_offset     => user_data_offset,
    user_data_write      => user_data_write,
    user_data_commit_len => user_data_commit_len,
    user_data_commit     => user_data_commit,
    user_data_free       => user_data_free,
    user_data_reset      => user_data_reset
      );

end RTL;
