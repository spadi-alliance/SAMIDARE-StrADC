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

-- NOTE: this has not been checked to actually work correctly!

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.fnet_records.all;

entity fnet_crc32_d32 is
  port (d32     : in  std_logic_vector(31 downto 0);
        crc_in  : in  std_logic_vector(31 downto 0);
        crc_out : out std_logic_vector(31 downto 0)
        );
end fnet_crc32_d32;

architecture RTL of fnet_crc32_d32 is

  signal c : std_logic_vector(31 downto 0);
  signal d : std_logic_vector(31 downto 0);
  signal o : std_logic_vector(31 downto 0);

  -- Temporary (to use common subexpressions)
  signal p : std_logic_vector(1 to 56);

begin

  d <= d32;
  c <= crc_in;

  p( 1) <= d( 0) xor d( 5) xor d( 7) xor c(24) xor c(26) xor c(31); -- 7
  p( 2) <= d( 3) xor d( 6) xor d(15) xor c(16) xor c(25) xor c(28); -- 5
  p( 3) <= d( 4) xor d(14) xor c( 1) xor c( 9) xor c(17) xor c(27); -- 5
  p( 4) <= d( 0) xor d(12) xor c( 2) xor c( 3) xor c(19) xor c(31); -- 5
  p( 5) <= d( 7) xor d(10) xor c( 4) xor c( 5) xor c(21) xor c(24); -- 5
  p( 6) <= d( 6) xor d( 9) xor d(11) xor c(20) xor c(22) xor c(25); -- 5
  p( 7) <= d( 2) xor d( 4) xor d( 8) xor c(23) xor c(27) xor c(29); -- 5
  p( 8) <= d( 1) xor d( 2) xor c( 0) xor c(12) xor c(29) xor c(30); -- 3
  p( 9) <= d( 1) xor d(13) xor d(15) xor c( 7) xor c(16) xor c(18); -- 3
  p(10) <= d( 2) xor d(11) xor d(12) xor c( 6) xor c(19) xor c(20); -- 3
  p(11) <= d( 8) xor d(14) xor c( 4) xor c( 8) xor c(17) xor c(23); -- 3
  p(12) <= d( 1) xor d( 3) xor d( 7) xor c( 8) xor c(24) xor c(28); -- 3
  p(13) <= d( 3) xor d(15) xor c( 0) xor c(13) xor c(16) xor c(28); -- 2
  p(14) <= p( 9) xor d(14) xor c( 1) xor c( 2) xor c(14) xor c(17); -- 2
  p(15) <= p( 4) xor d( 6) xor d(13) xor c( 8) xor c(15) xor c(18); -- 2
  p(16) <= d( 3) xor c( 0) xor c( 1) xor c( 3) xor c(10) xor c(28); -- 2
  p(17) <= p( 6) xor d( 1) xor c( 1) xor c( 5) xor c( 6) xor c(14); -- 2
  p(18) <= d( 2) xor d(10) xor c( 2) xor c( 7) xor c( 8) xor c(21); -- 2
  p(19) <= d( 7) xor d( 8) xor c( 5) xor c(23) xor c(24) xor c(29); -- 2
  p(20) <= p( 3) xor d( 0) xor c( 0) xor c(13) xor c(15) xor c(31); -- 2
  p(21) <= d( 9) xor d(13) xor c( 5) xor c(10) xor c(13) xor c(18); -- 2
  p(22) <= p( 1) xor d( 3) xor d( 8) xor d(12) xor c( 6) xor c(10); -- 2
  p(23) <= d( 5) xor d(10) xor c(12) xor c(21) xor c(26) xor c(30); -- 2
  p(24) <= d( 3) xor d( 9) xor d(10) xor c(21) xor c(22) xor c(28); -- 2
  p(25) <= p( 7) xor d( 5) xor d( 6) xor c( 7) xor c(25) xor c(26); -- 2
  p(26) <= d( 7) xor c( 6) xor c(11) xor c(24); -- 2
  p(27) <= p( 2) xor c( 0) xor c( 3) xor c(15); -- 2
  p(28) <= d( 2) xor d(13) xor c(11) xor c(18); -- 2
  p(29) <= d( 5) xor c(14) xor c(26) xor c(29); -- 2
  p(30) <= c( 3) xor c( 7) xor c(11) xor c(15); -- 2
  p(31) <= d( 4) xor d(11) xor c(20) xor c(27); -- 2
  p(32) <= d( 5) xor d( 9) xor c(22) xor c(26); -- 2
  p(33) <= d( 0) xor c( 9) xor c(13) xor c(31); -- 2
  p(34) <= p(22) xor c(19) xor c(23) xor c(28); -- 2
  p(35) <= d( 2) xor d( 4) xor c(27) xor c(29); -- 2
  p(36) <= p( 1) xor c( 9); -- 4
  p(37) <= c( 7) xor c(14); -- 4
  p(38) <= d(13) xor c(18); -- 4
  p(39) <= d(11) xor c(20); -- 3
  p(40) <= d(14) xor c(17); -- 3
  p(41) <= d(15) xor c(16); -- 3
  p(42) <= p(36) xor c( 6); -- 2
  p(43) <= c( 8) xor c(13); -- 2
  p(44) <= p(37) xor c(10); -- 2
  p(45) <= p(39) xor c( 4); -- 2
  p(46) <= d( 0) xor c(11); -- 2
  p(47) <= d( 9) xor c(22); -- 2
  p(48) <= c( 2) xor c(12); -- 2
  p(49) <= p( 3) xor c(12); -- 2
  p(50) <= c( 8) xor c(15); -- 2
  p(51) <= p( 5) xor d(12); -- 2
  p(52) <= d( 4) xor c(27); -- 2
  p(53) <= p(38) xor c( 0); -- 2
  p(54) <= d(10) xor c(21); -- 2
  p(55) <= p(12) xor c( 5); -- 2
  p(56) <= p( 7) xor c(30); -- 2

  o( 0) <= p(42) xor p( 8) xor p( 2) xor c(10);
  o( 1) <= p(49) xor p(26) xor p(13) xor c( 7);
  o( 2) <= p(43) xor p(42) xor p(14) xor c( 0) xor c(30);
  o( 3) <= p(44) xor p(15) xor p( 3) xor c(25);
  o( 4) <= p(45) xor p(26) xor p(15) xor p( 8) xor c(25);
  o( 5) <= p(16) xor p(10) xor p( 5) xor c( 7) xor c(13) xor c(29);
  o( 6) <= p(18) xor p(17) xor c( 4) xor c(11) xor c(29) xor c(30);
  o( 7) <= p(47) xor p(27) xor p(19) xor p(18) xor c(10);
  o( 8) <= p(47) xor p(46) xor p(16) xor p(11) xor c(12) xor c(31);
  o( 9) <= p(48) xor p(28) xor p(19) xor c( 1) xor c( 4) xor c( 9) xor c(13);
  o(10) <= p(29) xor p(13) xor p( 4) xor d( 2) xor c( 5) xor c( 9);
  o(11) <= p(49) xor p(45) xor p(27) xor p( 1) xor c(14);
  o(12) <= p(48) xor p(38) xor p(20) xor p( 5) xor d( 1) xor c( 6) xor c(30);
  o(13) <= p(37) xor p(21) xor p( 4) xor p( 2) xor c( 1) xor c( 6) xor c(22);
  o(14) <= p(30) xor p(29) xor p(11) xor p(10) xor c( 2);
  o(15) <= p(50) xor p(31) xor p( 9) xor p( 5) xor c( 3) xor c( 9) xor c(12) xor c(30);
  o(16) <= p(51) xor p(43) xor p(40) xor p(32) xor p( 8) xor c(19);
  o(17) <= p(52) xor p(38) xor p(33) xor p(17) xor d( 8) xor c(23) xor c(30);
  o(18) <= p(54) xor p(37) xor p(34) xor c( 2) xor c(15);
  o(19) <= p(41) xor p(35) xor p(30) xor p( 6) xor d( 7) xor c( 8) xor c(24);
  o(20) <= p(23) xor p(11) xor p( 2) xor d( 1) xor c( 9);
  o(21) <= p(40) xor p(36) xor p(35) xor p(21) xor c(22);
  o(22) <= p(53) xor p(41) xor p(36) xor p( 7) xor d(12) xor c(11) xor c(12) xor c(14) xor c(19);
  o(23) <= p(41) xor p(20) xor p(10) xor d( 5) xor c(26) xor c(29);
  o(24) <= p(54) xor p(31) xor p(14) xor d( 3) xor c(10) xor c(28) xor c(30);
  o(25) <= p(50) xor p(40) xor p(28) xor p(24) xor p( 4) xor c(29);
  o(26) <= p(53) xor p(34) xor p( 6) xor c( 3) xor c( 4);
  o(27) <= p(51) xor p(39) xor p(25) xor c( 1) xor c(11) xor c(19);
  o(28) <= p(55) xor p(52) xor p(23) xor p( 6) xor c( 2) xor c( 6);
  o(29) <= p(33) xor p(25) xor p(24) xor c( 3) xor c( 6);
  o(30) <= p(56) xor p(44) xor p(32) xor p(12) xor c( 4);
  o(31) <= p(56) xor p(55) xor p(46) xor d( 6) xor c( 9) xor c(15) xor c(25) xor c(31);

  crc_out <= o;

end RTL;
