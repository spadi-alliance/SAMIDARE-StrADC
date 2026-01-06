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
use ieee.std_logic_unsigned.ALL;

use work.fnet_records.all;
use work.fnet_util_pkg.all;

entity data_gen_user is
  port (
    clk              : in  std_logic;

    -- Output.
    event_word       : out std_logic_vector(31 downto 0);
    event_offset     : out std_logic_vector( 9 downto 0);
    event_write      : out std_logic;
    event_commit_len : out std_logic_vector( 10 downto 0);
    event_commit     : out std_logic;
    event_free       : in  std_logic;
    event_reset      : in  std_logic
    );

end data_gen_user;

architecture RTL of data_gen_user is

  type wrk_state is (IDLE,
                     START_EVENT,
                     SENDING_EVENT,
                     END_EVENT,
                     REST
                     );

  signal state : wrk_state := IDLE;

  signal ev_word       : std_logic_vector(event_word'range);
  signal ev_offset     : std_logic_vector(event_offset'range);
  signal ev_write      : std_logic;
  signal ev_commit_len : std_logic_vector(event_commit_len'range);
  signal ev_commit     : std_logic;

  signal payload_len   : unsigned(event_offset'range);
  signal data_length   : unsigned(event_commit_len'range);

  signal ev_count      : unsigned(1 downto 0) := (others => '0');

  signal rest_count : integer range 0 to 2000 := 0;
  
  signal cc : std_logic_vector(31 downto 0) := (others => '0');


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
      cc <= cc + '1';
    end if;
  end process;

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
          rest_count <= 0;
          
          state <= SENDING_EVENT;          

          ev_count <= ev_count + 1;

        when SENDING_EVENT =>
          ev_word <= cc;
          ev_offset <= std_logic_vector(data_length(9 downto 0)+1) ;
          ev_write <= '1';

          data_length <= data_length + 1;
          if (data_length >= 10) then
            state <= END_EVENT;
          end if;

        when END_EVENT =>
          ev_word <= X"ABCDABCD";
          ev_offset <= (others => '0');
          ev_write <= '1';

          ev_commit_len <= std_logic_vector(data_length + 1);
          ev_commit <= '1';
          state <= REST;
          rest_count <= 0;
          
        when REST =>
          ev_write <= '0';
          ev_commit <= '0';
          rest_count <= rest_count + 1;
          if (rest_count >= 200) then
            state <= IDLE;
          end if;
         

      end case;

      if (event_reset = '1') then
        state    <= IDLE;
        ev_count <= (others => '0');
      end if;

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
--probe0(41 downto 32) => ev_offset,
--probe0(52 downto 42) => ev_commit_len,
--probe0(53)      => ev_write,
--probe0(54)     => ev_commit,
--probe0(55)       => event_free,
--probe0(56)       => event_reset,

--probe0(66 downto 57) =>  std_logic_vector(payload_len),
--probe0(77 downto 67) =>  std_logic_vector(data_length),

--  probe0(499 downto 78)       => (others => '0')
        
--);
  
  
  
end RTL;
