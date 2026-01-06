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

library xpm;
use xpm.vcomponents.all;

use work.fnet_records.all; -- For word32_array.

entity efb_sampler is
  port (
    clk           : in  std_logic;
    clk_x2        : in  std_logic;
    clk_x4        : in  std_logic;
    clk_x4_90     : in  std_logic;
    -- Signals to sample.
    i_input       : in  std_logic_vector;
    -- The time counter.
    i_cycle_count : in  unsigned(31 downto 0);
    -- Monitor data stream.
    o_mon_data_array   : out word32_array;
    o_mon_has_data     : out std_logic_vector;
    i_mon_data_pending : in  std_logic_vector
    );

end efb_sampler;

architecture RTL of efb_sampler is

  type bits18_array is
    array (integer range <>) of std_logic_vector(17 downto 0);

  signal sample_x1   : bits18_array(i_input'range) :=
    (others => (others => '0'));

  signal write_sample : std_logic_vector(i_input'range) := (others => '0');

  -- Monitor data stream.
  signal mon_data_array : word32_array(o_mon_data_array'range) :=
    (others => (others=>'0'));
  signal mon_has_data   : std_logic_vector(o_mon_has_data'range) :=
    (others => '0');

begin

  lhs: for i in i_input'range generate
    -- Sample the input data with x4 clock (e.g. 500 MHz when clk is
    -- 125 Mhz).  Oversample with factor 4, so actual sample rate is 2
    -- GHz (0.5 ns).
    hs: entity work.efb_sample_x16
      port map(clk       => clk,
               clk_x2    => clk_x2,
               clk_x4    => clk_x4,
               clk_x4_90 => clk_x4_90,
               i_input   => i_input(i),
               o_samples => sample_x1(i)
               );

    -- Prepare data for output array.
    mon_data_array(i*2  ) <= "00000010" &
                             std_logic_vector(to_unsigned(i+1,4)) &
                             "00" &
                             sample_x1(i);
    mon_data_array(i*2+1) <= std_logic_vector(i_cycle_count);

    -- If any bit flipped in the raw data, then store the sample.
    -- NOTE: can only write when previous block written, i.e.
    -- last word no longer pending.
    write_sample(i) <=
      '1' when
      (((sample_x1(i)(17 downto 1) xor
         sample_x1(i)(16 downto 0)) /= "00000000000000000") and
       (i_mon_data_pending(i*2+1) = '0')) else '0';

    mon_has_data(i*2 to i*2+1) <= (others => write_sample(i));
  end generate;

  -- Sampler data format:
  --
  -- 00000010 cccc00ss ssssssss ssssssss : mark, channel and 18 bit raw data
  -- tttttttt tttttttt tttttttt tttttttt : clock counter @ sample

  o_mon_data_array <= mon_data_array;
  o_mon_has_data   <= mon_has_data;
 
end RTL;

