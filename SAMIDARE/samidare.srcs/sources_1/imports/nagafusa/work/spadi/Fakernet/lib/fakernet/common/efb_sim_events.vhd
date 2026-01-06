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

use work.fnet_records.all;
use work.fnet_util_pkg.all;

entity efb_sim_events is
  port (
    clk              : in  std_logic;

    -- Generation options.
    gen_ts           : in  std_logic;

    -- Output.
    event_word       : out std_logic_vector(31 downto 0);
    event_offset     : out std_logic_vector( 4 downto 0);
    event_write      : out std_logic;
    event_commit_len : out std_logic_vector( 4 downto 0);
    event_commit     : out std_logic;
    event_free       : in  std_logic;
    event_reset      : in  std_logic
    );

end efb_sim_events;

architecture RTL of efb_sim_events is

  type wrk_state is (IDLE,
                     START_EVENT,
                     EMIT_TS_LOW,
                     EMIT_TS_HIGH,
                     CHOOSE_PAYLOAD,
                     EMIT_SINGLE,
                     EMIT_LONG,
                     EMIT_MSG,
                     EMIT_HEADER);

  signal state : wrk_state := IDLE;

  signal ev_word       : std_logic_vector(event_word'range);
  signal ev_offset     : std_logic_vector(event_offset'range);
  signal ev_write      : std_logic;
  signal ev_commit_len : std_logic_vector(event_commit_len'range);
  signal ev_commit     : std_logic;

  signal payload_len   : unsigned(event_offset'range);
  signal data_length   : unsigned(event_commit_len'range);

  signal ev_count      : unsigned(1 downto 0) := (others => '0');

  signal ts_counter    : unsigned(63 downto 0) := (others => '0');

  signal prng_lfsr1 : std_logic_vector(15 downto 0) := (others => '1');
  signal prng_lfsr2 : std_logic_vector(15 downto 0) := (others => '1');

  -- "\n\nHello World!\n\n"
  signal message : std_logic_vector(4*32-1 downto 0) :=
    i2slv16(16#0a0a#) & i2slv16(16#4865#) &
    i2slv16(16#6c6c#) & i2slv16(16#6f20#) &
    i2slv16(16#576f#) & i2slv16(16#726c#) &
    i2slv16(16#6421#) & i2slv16(16#0a0a#);

Component ila_0 is 
port (
clk : in std_logic;
probe0 : in std_logic_vector(499 downto 0)
);
end Component;

begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      -- Default, no write.
      ev_write  <= '0';
      ev_commit <= '0';

      case (state) is

        when IDLE =>
          if (event_free = '1') then
            state <= START_EVENT;
          end if;

        when START_EVENT =>
          payload_len <= (others => '0');
          data_length <= (others => '0'); -- Header.
          if (gen_ts = '1') then
            state <= EMIT_TS_LOW;
          else
            state <= CHOOSE_PAYLOAD;
          end if;

          ev_count <= ev_count + 1;
          ts_counter <= ts_counter + 1001;

        when EMIT_TS_LOW =>
          ev_word <= std_logic_vector(ts_counter(31 downto 0));
          ev_offset <= std_logic_vector(data_length + 1);
          ev_write <= '1';

          data_length <= data_length + 1;
          state <= EMIT_TS_HIGH;

        when EMIT_TS_HIGH =>
          ev_word <= std_logic_vector(ts_counter(63 downto 32));
          ev_offset <= std_logic_vector(data_length + 1);
          ev_write <= '1';

          data_length <= data_length + 1;
          state <= CHOOSE_PAYLOAD;

        when CHOOSE_PAYLOAD =>
          if (prng_lfsr1(0) = '0') then
            state <= EMIT_HEADER;
          elsif (prng_lfsr2(0) = '0') then
            state <= EMIT_SINGLE;
          elsif (prng_lfsr2(1) = '0') then
            state <= EMIT_LONG;
          else
            state <= EMIT_MSG;
          end if;

        when EMIT_SINGLE =>
          ev_word <= i2slv16(16#c000#) & i2slv16(16#100f#); -- coooloff
          ev_offset <= std_logic_vector(data_length + 1);
          ev_write <= '1';

          payload_len <= payload_len + 1;
          data_length <= data_length + 1;
          state <= EMIT_HEADER;

        when EMIT_LONG =>
          ev_word <= "10100000" & "01010101" & "00001000" & "00000000";
          ev_word(payload_len'range) <= std_logic_vector(payload_len + 1);
          ev_offset <= std_logic_vector(data_length + 1);
          ev_write <= '1';

          payload_len <= payload_len + 1;
          data_length <= data_length + 1;

          if (payload_len(payload_len'high) = '1' or
              prng_lfsr1(2 downto 0) = "000") then
            state <= EMIT_HEADER;
          end if;

        when EMIT_MSG =>
          ev_word <= message((3-to_integer(payload_len))*32+31 downto
                             (3-to_integer(payload_len))*32);
          ev_offset <= std_logic_vector(data_length + 1);
          ev_write <= '1';

          payload_len <= payload_len + 1;
          data_length <= data_length + 1;

          if (payload_len = 3) then
            state <= EMIT_HEADER;
          end if;

        when EMIT_HEADER =>
          ev_word(31 downto 24) <= "00000000";
          ev_word(23 downto 22) <= "0" & gen_ts;
          ev_word(21 downto 20) <= std_logic_vector(ev_count);
          ev_word(19 downto 16) <= "0011"; -- trig
          ev_word(15 downto payload_len'high+1) <= (others => '0');
          ev_word(payload_len'range) <= std_logic_vector(payload_len);
          ev_offset <= (others => '0');
          ev_write <= '1';

          ev_commit_len <= std_logic_vector(data_length + 1);
          ev_commit <= '1';
          state <= IDLE;

      end case;

      if (event_reset = '1') then
        state    <= IDLE;
        ev_count <= (others => '0');
      end if;

      prng_lfsr1(15 downto 1) <= prng_lfsr1(14 downto 0);
      prng_lfsr1(0) <= prng_lfsr1(15) xor prng_lfsr1(13);

      prng_lfsr2(15 downto 1) <= prng_lfsr2(14 downto 0);
      prng_lfsr2(0) <= prng_lfsr2(15) xor prng_lfsr2(11);
    end if;
  end process;

  event_word       <= ev_word;
  event_offset     <= ev_offset;
  event_write      <= ev_write;
  event_commit_len <= ev_commit_len;
  event_commit     <= ev_commit;
  

--ila_i : ila_0  
--port map(
--clk => clk,
--probe0(31 downto 0) => ev_word,
--probe0(36 downto 32) => ev_offset,
--probe0(41 downto 37) => ev_commit_len,
--probe0(42)      => ev_write,
--probe0(43)     => ev_commit,
--probe0(44)       => event_free,
--probe0(45)       => event_reset,

--probe0(50 downto 46) =>  std_logic_vector(payload_len),
--probe0(55 downto 51) =>  std_logic_vector(data_length),
--probe0(56)       => gen_ts,
--  probe0(499 downto 57)       => (others => '0')
        
--);
  
  
  
end RTL;
