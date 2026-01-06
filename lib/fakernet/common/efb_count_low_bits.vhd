-- Copyright (c) 2017, Haakan T. Johansson
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

-- From DPTC.

-- Count the number of low bits set in x, return result in y.
-- It is required that the set bits are continuous, and then
-- no bits are set, e.g. "00011111", not "00010111".

-- Currently the code at most supports counting 32 bits.

-- Careful: giving e.g. a 16-bit input vector which always have at
-- least one bit requires a _five_-bit output word, since the minimum
-- count is 1, and the maximum is 16.

entity efb_count_low_bits is
    port (x : in std_logic_vector;
          y : out std_logic_vector
          );
end;

architecture RTL of efb_count_low_bits is

    -- Alias (to have a shorter name, and also fixed (larger) length).
    signal p : std_logic_vector(32 downto 1);
    -- Alias for output values
    signal pb1, pb2, pb4, pb8, pb16, pb32 : std_logic;
    -- Alias for output (to have fixed (larger) length).
    signal pbv : std_logic_vector(5 downto 0);

begin
    p(x'length downto 1) <= x;
    p(32 downto x'length+1) <= (others => '0');
            
    pb1 <= -- For bit 1, odd values must be set, but not the next higher
        (p( 1) and not p( 2)) or (p( 3) and not p( 4)) or
        (p( 5) and not p( 6)) or (p( 7) and not p( 8)) or
        (p( 9) and not p(10)) or (p(11) and not p(12)) or
        (p(13) and not p(14)) or (p(15) and not p(16)) or
        (p(17) and not p(18)) or (p(19) and not p(20)) or
        (p(21) and not p(22)) or (p(23) and not p(24)) or
        (p(25) and not p(26)) or (p(27) and not p(28)) or
        (p(29) and not p(30)) or (p(31) and not p(32));
    pb2 <= -- For bit two, value mod 4 must be 2 or 3, but not the next higher
        ((p( 2) or p( 3)) and not p( 4)) or ((p( 6) or p( 7)) and not p( 8)) or
        ((p(10) or p(11)) and not p(12)) or ((p(14) or p(15)) and not p(16)) or
        ((p(18) or p(19)) and not p(20)) or ((p(22) or p(23)) and not p(24)) or
        ((p(26) or p(27)) and not p(28)) or ((p(30) or p(31)) and not p(32));
    pb4 <= -- For bit three, value mod 8 must be 4..7, but not next higher
        ((p( 4) or p( 5) or p( 6) or p( 7)) and not p( 8)) or
        ((p(12) or p(13) or p(14) or p(15)) and not p(16)) or
        ((p(20) or p(21) or p(22) or p(23)) and not p(24)) or
        ((p(28) or p(29) or p(30) or p(31)) and not p(32));
    pb8 <= -- For bit four, value mod %16 must be 8..15, but not next higher
        ((p( 8) or p( 9) or p(10) or p(11) or
          p(12) or p(13) or p(14) or p(15)) and not p(16)) or
        ((p(24) or p(25) or p(26) or p(27) or
          p(28) or p(29) or p(30) or p(31)) and not p(32));
    pb16 <= -- For bit four, %16 must be 8..15, but not next higher
        ((p(16) or p(17) or p(18) or p(19) or
          p(20) or p(21) or p(22) or p(23) or
          p(24) or p(25) or p(26) or p(27) or
          p(28) or p(29) or p(30) or p(31)) and not p(32));
    pb32 <= p(32);

    -- Combine to a number
    pbv <= pb32 & pb16 & pb8 & pb4 & pb2 & pb1;

    y <= pbv(y'range);

end RTL;
