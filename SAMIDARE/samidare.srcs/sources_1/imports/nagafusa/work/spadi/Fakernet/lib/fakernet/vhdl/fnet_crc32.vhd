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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.fnet_records.all;

entity fnet_crc32 is
  port (d16     : in  std_logic_vector(15 downto 0);
        crc_in  : in  std_logic_vector(31 downto 0);
        crc_out : out std_logic_vector(31 downto 0)
        );
end fnet_crc32;

architecture RTL of fnet_crc32 is

  signal c : std_logic_vector(31 downto 0);
  signal d : std_logic_vector(15 downto 0);
  signal o : std_logic_vector(31 downto 0);

  -- Temporary (to use common subexpressions)
  signal p : std_logic_vector(1 to 32);

begin

  d <= d16;
  c <= crc_in;

  p( 1) <= d( 2) xor d( 9) xor d(14) xor c(17) xor c(22) xor c(29); -- 7
  p( 2) <= d( 1) xor d( 8) xor d(13) xor c(18) xor c(23) xor c(30); -- 7
  p( 3) <= d( 0) xor d( 7) xor d(12) xor c(19) xor c(24) xor c(31); -- 7
  p( 4) <= d( 3) xor d( 6) xor d(15) xor c(16) xor c(25) xor c(28); -- 5
  p( 5) <= d( 4) xor d(11) xor d(14) xor c(17) xor c(20) xor c(27); -- 4
  p( 6) <= d( 5) xor d(12) xor d(15) xor c(16) xor c(19) xor c(26); -- 3
  p( 7) <= d( 2) xor d( 6) xor d(10) xor c(21) xor c(25) xor c(29); -- 3
  p( 8) <= p( 3) xor d( 4) xor d( 9) xor d(11) xor c(20) xor c(22); -- 2
  p( 9) <= d( 8) xor d(10) xor d(11) xor c(20) xor c(21) xor c(23); -- 2
  p(10) <= d( 7) xor d( 9) xor d(10) xor c(21) xor c(22) xor c(24); -- 2
  p(11) <= d( 3) xor d( 7) xor d(11) xor c(20) xor c(24) xor c(28); -- 2
  p(12) <= d( 3) xor d(13) xor c(18) xor c(28); -- 3
  p(13) <= d( 5) xor d( 9) xor c(22) xor c(26); -- 2
  p(14) <= d( 4) xor d( 8) xor c(23) xor c(27); -- 2
  p(15) <= p( 1) xor d( 6) xor d(15) xor c(16); -- 2
  p(16) <= p( 2) xor d( 5) xor d(14) xor c(17); -- 2
  p(17) <= d( 5) xor d( 8) xor c(23) xor c(26); -- 2
  p(18) <= d(10) xor d(13) xor c(18) xor c(21); -- 2
  p(19) <= d( 1) xor d(12) xor c(19) xor c(30); -- 2
  p(20) <= p( 4) xor d( 0) xor d(11) xor c(20); -- 2
  p(21) <= d( 6) xor d(10) xor c(21) xor c(25); -- 2

  -- Note: there are some subexpressions here that could be used
  -- above as well...  However, testing shows that it does not
  -- help (same or more LUTs used).

  p(22) <= d( 7) xor c(24); -- 4
  p(23) <= d( 6) xor c(25); -- 4
  p(24) <= d(15) xor c(16); -- 4
  p(25) <= d(10) xor c(21); -- 3
  p(26) <= d( 4) xor c(27); -- 3
  p(27) <= p(23) xor p( 3); -- 2
  p(28) <= d(12) xor c(19); -- 2
  p(29) <= p(15) xor c(25); -- 2
  p(30) <= d(11) xor c(20); -- 2
  p(31) <= d( 8) xor c(23); -- 2
  p(32) <= d( 9) xor c(22); -- 2

  o( 0) <= p(13) xor p( 4);
  o( 1) <= p(14) xor p( 4) xor p( 1);
  o( 2) <= p(29) xor p(22) xor p( 2);
  o( 3) <= p(27) xor p(16) xor c(26);
  o( 4) <= p(24) xor p(12) xor p( 8) xor c(27);
  o( 5) <= p( 9) xor p( 6) xor p( 1);
  o( 6) <= p(10) xor p( 5) xor p( 2);
  o( 7) <= p(24) xor p(18) xor p(17) xor p( 3);
  o( 8) <= p(22) xor p( 6) xor p( 5) xor d( 3) xor c(28);
  o( 9) <= p(12) xor p( 7) xor p( 5);
  o(10) <= p(24) xor p(19) xor p( 7) xor d(13) xor c(18);
  o(11) <= p(20) xor p(19) xor d(14) xor c(17) xor c(31);
  o(12) <= p(20) xor p(18) xor p( 1) xor c(31);
  o(13) <= p(28) xor p(25) xor p( 2) xor p( 1) xor d( 5) xor c(26);
  o(14) <= p( 8) xor p( 2) xor c(27);
  o(15) <= p(27) xor p( 9) xor d( 3) xor c(28);
  o(16) <= p(25) xor p(24) xor p(11) xor d( 2) xor c( 0) xor c(29);
  o(17) <= p(21) xor p( 1) xor d( 1) xor c( 1) xor c(30);
  o(18) <= p(13) xor p( 2) xor d( 0) xor c( 2) xor c(31);
  o(19) <= p(14) xor p( 3) xor c( 3);
  o(20) <= p(23) xor p(11) xor c( 4);
  o(21) <= p( 7) xor d( 5) xor c( 5) xor c(26);
  o(22) <= p(26) xor p( 4) xor d( 1) xor c( 6) xor c(30);
  o(23) <= p(29) xor d( 0) xor c( 7) xor c(31);
  o(24) <= p(16) xor c( 8) xor c(26);
  o(25) <= p(26) xor p( 3) xor d(13) xor c( 9) xor c(18);
  o(26) <= p(32) xor p(30) xor p( 6) xor c(10);
  o(27) <= p(31) xor p(25) xor p( 5) xor c(11);
  o(28) <= p(12) xor p(10) xor c(12);
  o(29) <= p(32) xor p(31) xor p(28) xor p(23) xor d( 2) xor c(13) xor c(29);
  o(30) <= p(30) xor p(22) xor p(17) xor d( 1) xor c(14) xor c(30);
  o(31) <= p(26) xor p(22) xor p(21) xor d( 0) xor c(15) xor c(31);

  crc_out <= o;

end RTL;
