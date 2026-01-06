-- Copyright (C) 2017, Haakan T. Johansson
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

package fnet_util_pkg is

  function fnet_max(x, y : integer) return integer;

  function fnet_if_true(p : in boolean;
                        x : in natural;
                        y : natural) return natural;

  function fnet_log2(x : natural) return natural;

  function fnet_or_reduction(slv : in std_logic_vector) return std_logic;

  function fnet_bit_reverse (slv : in std_logic_vector)
    return std_logic_vector;

  function find_highest(v : std_logic_vector) return integer;

  function find_lowest(v : std_logic_vector) return integer;

  function i2slv16(i : integer) return std_logic_vector;

  function i2slv32(i : integer) return std_logic_vector;

  type frac_int_array is
    array (integer range <>) of integer;

  function frac_int_vector(n : natural;
                           mul : integer;
                           div : integer) return frac_int_array;

  function fnet_string_to_slv(s : string;
                              n : natural) return std_logic_vector;

end fnet_util_pkg;

package body fnet_util_pkg is

  function fnet_max(x, y : integer) return integer is
  begin
    if x > y then
      return x;
    else
      return y;
    end if;
  end function;

  function fnet_if_true(p : in boolean;
                        x : in natural;
                        y : natural) return natural is
  begin
    if (p) then
      return x;
    else
      return y;
    end if;
  end function;

  -- Call as log2(x)     =>  1->0   2,3->1    4,5,6,7->2
  -- Call as log2(x-1)+1 => (1->0)  2  ->1  3,4      ->2  5,6,7,8 -> 3
  function fnet_log2 (x : natural) return natural is
    variable temp, log: natural;
  begin
    if (x = 1) then -- avoid warning about zero number of iterations
      return 0;
    end if;
    temp := x / 2;
    log := 0;
    while (temp /= 0) loop
      temp := temp/2;
      log := log + 1;
    end loop;
    return log;
  end function;

  function fnet_or_reduction(slv : in std_logic_vector) return std_logic is
    variable res : std_logic := '0';
  begin
    for i in slv'range loop
      res := res or slv(i);
    end loop;
    return res;
  end function;

  function fnet_bit_reverse (slv : in std_logic_vector)
    return std_logic_vector is
    variable res : std_logic_vector(slv'range);
  begin
    for i in slv'range loop
      res(i) := slv(slv'low + slv'high - i);
    end loop;
    return res;
  end;

  function find_highest(v : std_logic_vector) return integer is
    variable high_i : integer := 0;
  begin
    for i in v'low to v'high loop
      if (v(i) = '1') then
        high_i := i-v'low;
      end if;
    end loop;
    return high_i;
  end function;

  function find_lowest(v : std_logic_vector) return integer is
    variable low_i : integer := 0;
  begin
    for i in v'high downto v'low loop
      if (v(i) = '1') then
        low_i := i-v'low;
      end if;
    end loop;
    return low_i;
  end function;

  function i2slv16(i : integer) return std_logic_vector is
    variable slv : std_logic_vector(15 downto 0);
  begin
    slv := std_logic_vector(to_unsigned(i, 16));
    return slv;
  end function;

  function i2slv32(i : integer) return std_logic_vector is
    variable slv : std_logic_vector(31 downto 0);
  begin
    slv := std_logic_vector(to_unsigned(i, 32));
    return slv;
  end function;

  -- Initialise integer vector of n elements with linearly (before
  -- rounding) increasing values.
  function frac_int_vector(n : natural;
                           mul : integer;
                           div : integer) return frac_int_array is
    variable arr : frac_int_array(0 to n-1);
  begin
    for i in 0 to n-1 loop
      arr(i) := (i * mul) / div;
    end loop;
    return arr;
  end;

  function fnet_string_to_slv(s : string;
                              n : natural) return std_logic_vector is
    variable slv : std_logic_vector(n * 8 - 1 downto 0) := (others => '0');
  begin
    for i in s'low to s'high loop
      slv((i - s'low + 1) * 8-1 downto
          (i - s'low    ) * 8) :=
        std_logic_vector(to_unsigned(character'pos(s(i)),8));
    end loop;
    return slv;
  end;

end;
