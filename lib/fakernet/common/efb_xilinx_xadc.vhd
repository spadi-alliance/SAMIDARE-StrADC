-- Copyright (c) 2023, Haakan T. Johansson
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

library UNISIM;
use UNISIM.VComponents.all;

-- XADC sampling takes 26 adcclk cycles.  adcclk = dclk / divider.
-- With a 250 MHz dclk and divider 16, adcclk = 15.625 MHz, which
-- is below the maximum of 26 MHz.  Typically, we provide a 125 MHz
-- input clock, so even further below.

entity efb_xilinx_xadc is
  port (
    clk                : in  std_logic; -- Clock from board
    -- Request monitor readout.
    i_mon_request      : in  std_logic;
    -- Monitor data stream (output).
    o_mon_data_array   : out std_logic_vector(31 downto 0);
    o_mon_has_data     : out std_logic;
    i_mon_data_pending : in  std_logic
    );

end efb_xilinx_xadc;

architecture RTL of efb_xilinx_xadc is

  type ro_state is (IDLE,
                    FIND_CH0,
                    READOUT);

  signal readout_state : ro_state := IDLE;
  
  -- XADC interface signals.
  signal xadc_dclk    : std_logic := '0';
  signal xadc_do      : std_logic_vector(15 downto 0) := (others => '0');
  signal xadc_daddr   : std_logic_vector( 6 downto 0) := (others => '0');
  signal xadc_den     : std_logic := '0';
  signal xadc_drdy    : std_logic := '0';
  signal xadc_channel : std_logic_vector( 4 downto 0) := (others => '0');
  signal xadc_eos     : std_logic := '0';
  signal xadc_eoc     : std_logic := '0';
  signal xadc_reset   : std_logic := '1';

  -- TODO: is this needed at all?
  signal reset_count : unsigned(1 downto 0) := "11";

begin

  xadc_inst : xadc
    generic map(init_40 => "1001000000000000", -- No calib avg.
                init_41 => "0010111111111110", -- Continuous sequencer,
                                               -- disable alarms, enable calib.
                init_42 => "0001000000000000", -- DCLK divider (16).

                init_48 => "0100011100000001", -- Sequencer; enabled channels.
                init_4a => "0100011100000000"  -- Averaging.
                )
    port map(
      dclk      => xadc_dclk,
      di        => (others => '0'),
      do        => xadc_do,
      daddr     => xadc_daddr,
      den       => xadc_den,
      dwe       => '0',
      drdy      => xadc_drdy,
      channel   => xadc_channel,
      eos       => xadc_eos,
      eoc       => xadc_eoc,
      reset     => xadc_reset,
      convst    => '0',
      convstclk => '0',
      vp        => '0',
      vn        => '0',
      vauxp     => (others => '0'),
      vauxn     => (others => '0'));

  xadc_dclk <= clk;

  process(clk)
  begin
    if (rising_edge(clk)) then

      if (reset_count /= "00") then
        reset_count <= reset_count - 1;
        xadc_reset <= '1';
      else
        xadc_reset <= '0';
      end if;

      -- Continuous sampling mode.  Read whatever was converted.
      xadc_den   <= xadc_eoc;
      xadc_daddr <= "00" & xadc_channel;

      -- General monitor output handling:
      --
      -- After i_mon_request we wait until channel 0 has been
      -- converted and is being read.  We then pass all values to the
      -- monitor until channel 0 is reached again.

      -- Default value.
      o_mon_has_data <= '0';

      case readout_state is
        when IDLE =>
          -- Wait for the request.
          if (i_mon_request = '1') then
            readout_state <= FIND_CH0;
          end if;

        when FIND_CH0 =>
          -- Wait until channel 0 being read.
          if (xadc_eoc = '1' and
              xadc_channel = "00000") then
            readout_state <= READOUT;
          end if;

        when READOUT =>
          if (xadc_drdy = '1') then
            -- We can now take the data!
            o_mon_has_data <= '1';
          end if;
          -- We are about to get channel 0 again, stop the passing
          -- along to monitor.
          if (xadc_eoc = '1' and
              xadc_channel = "00000") then
            readout_state <= IDLE;
          end if;          
      end case;

    end if;
  end process;

  -- XADC monitor data format:
  --
  -- 00000011 000ccccc dddddddd dddddddd : mark, channel and 16 bit raw data

  o_mon_data_array <=
    "00000011" & "000" & xadc_daddr(4 downto 0) & xadc_do;
  
end RTL;
