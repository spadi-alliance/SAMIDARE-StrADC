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

entity fnet_regaccess is
  port (clk            : in  std_logic;

        regacc_addr    : out std_logic_vector(24 downto 0) := (others=>'0');
        regacc_data_wr : out std_logic_vector(31 downto 0) := (others=>'0');
        regacc_data_rd : in  std_logic_vector(31 downto 0) := (others=>'0');
        regacc_write   : out std_logic := '0';
        regacc_read    : out std_logic := '0';
        regacc_done    : in  std_logic;
        regacc_cnt     : out std_logic_vector(3 downto 0);

        regacc_int_addr    : out std_logic_vector(24 downto 0) :=(others=>'0');
        regacc_int_data_wr : out std_logic_vector(31 downto 0) :=(others=>'0');
        regacc_int_data_rd : in  std_logic_vector(31 downto 0);
        regacc_int_write   : out std_logic := '0';
        regacc_int_read    : out std_logic := '0';
        regacc_int_done    : in  std_logic;
        regacc_int_cnt     : out std_logic_vector(3 downto 0) := (others=>'0');

        ram_stat_udp_regacc : in ram_stat_block;
        ram_stat_udp_regidp : in ram_stat_block;
        ram_stat_udp_regres : in ram_stat_block_array(0 to NUM_REG_CH-1);
        ram_cons_udp_regacc : out ram_cons_block;
        ram_prod_udp_regidp : out ram_prod_block;
        ram_prod_udp_regres : out ram_prod_block_array(0 to NUM_REG_CH-1);
        dp_ram_udp_regacc_porti : in  ram_block_porti_a11d16;
        dp_ram_udp_regacc_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_udp_regidp_porti : in  ram_block_porti_a11d16;
        dp_ram_udp_regidp_porto : out ram_block_porto_a11d16 := rbpo_zero;
        dp_ram_udp_regres_porti : in  ram_block_porti_a11d16_array(0 to NUM_REG_CH-1);
        dp_ram_udp_regres_porto : out ram_block_porto_a11d16_array(0 to NUM_REG_CH-1) := (others => rbpo_zero);
        regacc_stat_aux     : in regacc_aux_stat;

        debug_state    : out std_logic_vector(4 downto 0)
        );
end fnet_regaccess;

architecture RTL of fnet_regaccess is
  signal a : regaccess_async_state;

  signal s : regaccess_state :=
        (state => RSM_IDLE,
         cnt => (others => '0'),
         get_data => (others => '0'),
         accum_cksum => '0',
         wcksum => (others => '0')
         );

  signal w : std_logic_vector(15 downto 0);

  signal wr_op  : std_logic := '0';
  signal int_op : std_logic := '0';
  -- Count to 15.
  signal cnt    : std_logic_vector(3 downto 0) := (others => '0');
  signal cnt_256    : std_logic_vector(7 downto 0) := (others => '0');

  signal off         : std_logic_vector(10 downto 0) :=
    (0 => '0', others => '1');
  signal offp2       : std_logic_vector(10 downto 0);
  signal off_stored  : std_logic_vector(10 downto 0) := (others => '0');

  -- Additional pipeline stage to protect us from timing issues driving
  -- signals all over the chip, if external code uses/provides the values
  -- directly.
  signal regacc_pre_addr    : std_logic_vector(24 downto 0) := (others => '0');
  signal regacc_pre_data_wr : std_logic_vector(31 downto 0) := (others => '0');
  signal regacc_pst_int_data_rd : std_logic_vector(31 downto 0):=(others=>'0');
  signal regacc_pst_ext_data_rd : std_logic_vector(31 downto 0):=(others=>'0');
  signal regacc_pre_int_write : std_logic := '0';
  signal regacc_pre_int_read  : std_logic := '0';
  signal regacc_pre_ext_write : std_logic := '0';
  signal regacc_pre_ext_read  : std_logic := '0';
  signal regacc_pst_done  : std_logic := '0';

  signal regacc_pre2_addr    : std_logic_vector(24 downto 0) := (others => '0');
  signal regacc_pre2_data_wr : std_logic_vector(31 downto 0) := (others => '0');
  signal regacc_pst2_ext_data_rd : std_logic_vector(31 downto 0):=(others=>'0');
  signal regacc_pre2_ext_write : std_logic := '0';
  signal regacc_pre2_ext_read  : std_logic := '0';
  signal regacc_pst2_done  : std_logic := '0';
  signal regacc_pre2_cnt   : std_logic_vector(3 downto 0) := (others => '0');

  signal read_data : std_logic_vector(31 downto 0) := (others => '0');
  signal done_data : std_logic := '0';

  signal actual_woff  : std_logic_vector(10 downto 0);
  signal actual_wdata : std_logic_vector(15 downto 0);
  signal actual_wr    : std_logic;

  signal fold_wcksum       : std_logic_vector(16 downto 0);
  signal accum_wcksum      : std_logic_vector(16 downto 0);
  signal wdata_accum_cksum : std_logic_vector(15 downto 0);

  signal tmp_wcksum : std_logic_vector(16 downto 0);

  -- For debugging
  signal state_no : integer := 0;

begin

  offp2 <= off + 2;

  fold_wcksum <= ('0' & s.wcksum(15 downto 0)) + s.wcksum(16);

  accum_wcksum <= fold_wcksum;

  wdata_accum_cksum <=
    actual_wdata when (s.accum_cksum = '1') else (w'range => '0');

  tmp_wcksum <= accum_wcksum + wdata_accum_cksum;

  process (s, ram_stat_udp_regacc,
           ram_stat_udp_regidp, ram_stat_udp_regres,
           regacc_stat_aux,
           off, w,
           regacc_pst_done, cnt,
           offp2, wr_op, done_data, read_data, fold_wcksum)
  begin

    a <= (wdata => w,
          next_state => RSM_IDLE,
          latch_data => LATCH_NONE,
          latch_done => '0',
          reset_read => '0',
          reset => '0',
          off_update => ROU_NONE,
          off_store => '0',
          wr => '0',
          issue_read => '0',
          issue_write => '0',
          done => '0',
          wudpcksum => '0',
          next_accum_cksum => '0');

    case s.state is

      -------------------------------------------------------------
      -- Ethernet

      when RSM_IDLE =>
        a.next_state <= RSM_IDLE;
        -- Already the input process checked that the output buffer
        -- is empty.  It is checked there such that this process
        -- always succeeds, and the access is done in a timely
        -- fashion.  (The output may take long to clean if there is
        -- no good network link.)
        if (ram_stat_udp_regacc.hasdata = '1') then
          a.next_state <= RSM_FIRST;
        end if;
        a.off_update <= ROU_RESET;
        a.reset <= '1';

      when RSM_FIRST =>
        a.next_state <= RSM_HEADER;
        a.off_update <= ROU_INCREASE;

      when RSM_HEADER =>
        a.next_state <= RSM_HEADER;
        if (off = 48) then
          a.next_state <= RSM_NEXT_ACCESS;
        else
          a.off_update <= ROU_INCREASE;
        end if;
        a.wr <= '1';

        -------------------------------------------------------------

        -- We check for further access operations in an no-action
        -- state.  This avoids having to do the same thing in three
        -- other places.
      when RSM_NEXT_ACCESS =>
        if (offp2 = regacc_stat_aux.end_words) then
          if (off < 60) then
            a.next_state <= RSM_PAD;
          else
            a.next_state <= RSM_CK;
          end if;
        else
          a.next_state <= RSM_RADDR_1;
        end if;
        a.off_update <= ROU_INCREASE;
        a.off_store <= '1';

        -- The entire writing of the write or read commands are done
        -- after the access, since the first item holds the success mark

      when RSM_RADDR_1 =>
        a.next_state <= RSM_RADDR_2;
        a.latch_data <= LATCH_ADDR_1;
        a.off_update <= ROU_INCREASE;

      when RSM_RADDR_2 =>
        if (wr_op = '1') then
          a.next_state <= RSM_WRITE_RDATA_1;
          a.off_update <= ROU_INCREASE;
        else
          a.next_state <= RSM_READ_WAIT;
          a.off_update <= ROU_RESTORE;
          a.issue_read <= '1';
        end if;
        a.latch_data <= LATCH_ADDR_2;

        -------------------------------------------------------------

      when RSM_WRITE_RDATA_1 =>
        a.next_state <= RSM_WRITE_RDATA_2;
        a.latch_data <= LATCH_DATA_1;
        a.off_update <= ROU_INCREASE;

      when RSM_WRITE_RDATA_2 =>
        a.next_state <= RSM_WRITE_WAIT;
        a.latch_data <= LATCH_DATA_2;
        a.off_update <= ROU_RESTORE;
        a.issue_write <= '1';

      when RSM_WRITE_WAIT =>
        a.next_state <= RSM_WRITE_WAIT;
        if ((regacc_pst_done = '1') or
--            (cnt = 15)) then
            (cnt_256 = 255)) then
          a.next_state <= RSM_WRITE_WADDR_1;
          a.off_update <= ROU_INCREASE;
          --a.next_accum_cksum <= '1'; -- delay 1
        end if;
        a.latch_done <= '1';

      when RSM_WRITE_WADDR_1 =>
        a.next_state <= RSM_WRITE_WADDR_2;
        a.off_update <= ROU_INCREASE;
        -- Mark that the write was done (if it was).
        a.wdata <= '0' & done_data & "00" & w(11 downto 0);
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_WRITE_WADDR_2 =>
        a.next_state <= RSM_WRITE_WDATA_1;
        a.off_update <= ROU_INCREASE;
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_WRITE_WDATA_1 =>
        a.next_state <= RSM_WRITE_WDATA_2;
        a.off_update <= ROU_INCREASE;
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_WRITE_WDATA_2 =>
        a.next_state <= RSM_NEXT_ACCESS;
        a.wr <= '1';
        a.next_accum_cksum <= '1'; -- delayed

        -------------------------------------------------------------

      when RSM_READ_WAIT =>
        a.next_state <= RSM_READ_WAIT;
        if (regacc_pst_done = '1') then
          a.next_state <= RSM_READ_WADDR_1;
          a.off_update <= ROU_INCREASE;
          --a.next_accum_cksum <= '1'; -- delay 1
--        elsif (cnt = 15) then
        elsif (cnt_256 = 255) then
          a.next_state <= RSM_READ_WADDR_1;
          a.off_update <= ROU_INCREASE;
          --a.next_accum_cksum <= '1'; -- delay 1
          a.reset_read <= '1'; -- Write 0 as read response value.
        end if;
        a.latch_done <= '1';

      when RSM_READ_WADDR_1 =>
        a.next_state <= RSM_READ_WADDR_2;
        a.off_update <= ROU_INCREASE;
        -- Mark that the read was done (if it was).
        a.wdata <= "00" & '0' & done_data & w(11 downto 0);
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_READ_WADDR_2 =>
        a.next_state <= RSM_READ_WDATA_1;
        a.off_update <= ROU_INCREASE;
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_READ_WDATA_1 =>
        a.next_state <= RSM_READ_WDATA_2;
        a.off_update <= ROU_INCREASE;
        a.wdata <= read_data(31 downto 16);
        a.wr <= '1';
        a.next_accum_cksum <= '1';

      when RSM_READ_WDATA_2 =>
        a.next_state <= RSM_NEXT_ACCESS;
        a.wdata <= read_data(15 downto  0);
        a.wr <= '1';
        a.next_accum_cksum <= '1';

        -------------------------------------------------------------

      when RSM_PAD =>
        a.next_state <= RSM_PAD;
        if (off = 60) then
          a.next_state <= RSM_CK;
        end if;
        a.wdata <= (others => '0');
        a.off_update <= ROU_INCREASE;
        a.wr <= '1';

        -- TODO: Checksum worst case got value added at previous write.
        -- then was one cycle of RSM_NEXT_ACCESS.
        -- But the checksum might cause to wraps?
        -- Besides, we also would like to avoid the checksum (fold)
        -- calculation to have the async value as output?
      when RSM_CK =>
        a.next_state <= RSM_DONE;

      when RSM_DONE =>
        a.next_state <= RSM_IDLE;
        a.done <= '1';
        a.wdata <= not fold_wcksum(15 downto 0);
        a.wudpcksum <= '1';
        a.wr <= '1';

    end case;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      s.state <= a.next_state;

      case a.latch_data is
        when LATCH_NONE =>
        when LATCH_ADDR_1 =>
          wr_op <= w(15);
          -- 14..12 are ignored here.
          int_op <= w(11);
          -- 10 and 9 reserved for future use
          regacc_pre_addr(24 downto 16) <= w(8 downto 0);
        when LATCH_ADDR_2 =>
          regacc_pre_addr(15 downto  0) <= w;
        when LATCH_DATA_1 =>
          regacc_pre_data_wr(31 downto 16) <= w;
        when LATCH_DATA_2 =>
          regacc_pre_data_wr(15 downto  0) <= w;
      end case;

      if (a.reset_read = '1') then
        -- We never got a read response :-(
        read_data <= (others => '0');
      elsif (a.latch_done = '1') then
        -- We latch the entire read data word at the same cycle
        -- as the regacc_done is set.  We also do the latch such that
        -- we have no timing dependency on the outside code,
        -- by using a pipeline register.
        if (int_op = '1') then
          read_data <= regacc_pst_int_data_rd;
        else
          read_data <= regacc_pst_ext_data_rd;
        end if;
      end if;
      if (a.latch_done = '1') then
        done_data <= regacc_pst_done;
      end if;

      case a.off_update is
        when ROU_NONE     => null;
                             -- -2 (first read is at 0).
        when ROU_RESET    => off <= (0 => '0', others => '1');
        when ROU_INCREASE => off <= offp2;
        when ROU_RESTORE  => off <= off_stored;
      end case;

      --if (a.off_update = ROU_NONE) then
      --elsif (a.off_update = ROU_RESET) then
      --  -- -2 (first read is at 0).
      --  off <= (0 => '0', others => '1');
      --elsif (a.off_update = ROU_INCREASE) then
      --  off <= offp2;
      --elsif (a.off_update = ROU_RESTORE)  then
      --  off <= off_stored;
      --end if;

      if (a.off_store = '1') then
        off_stored <= off;
      end if;

      regacc_pre_int_read  <= a.issue_read  and     int_op;
      regacc_pre_int_write <= a.issue_write and     int_op;
      regacc_pre_ext_read  <= a.issue_read  and not int_op;
      regacc_pre_ext_write <= a.issue_write and not int_op;

      if (a.issue_read = '1' or
          a.issue_write = '1') then
        cnt <= (others => '0');
        cnt_256 <= (others => '0');
      else
        cnt <= cnt + 1;
        cnt_256 <= cnt_256 + 1;
      end if;

      if (a.reset = '1') then
        s.wcksum <= regacc_stat_aux.checksum;
      else
        s.wcksum <= tmp_wcksum;
      end if;

      s.accum_cksum <= a.next_accum_cksum;

      actual_woff <= off;
      if (a.wudpcksum = '1') then
        actual_woff <= std_logic_vector(to_unsigned(40,11));
      end if;
      actual_wdata <= a.wdata;
      actual_wr <= a.wr;

      -- Pipeline stage.

      -- Do an extra pipeline stage for outside access:
      -- then internal and external access do not use the same
      -- variables and will not alias and does not mess up
      -- timing if map stage does not duplicate registers.

      regacc_pre2_addr       <= regacc_pre_addr;
      regacc_pre2_data_wr    <= regacc_pre_data_wr;
      regacc_pre2_ext_read   <= regacc_pre_ext_read;
      regacc_pre2_ext_write  <= regacc_pre_ext_write;
      regacc_pre2_cnt        <= cnt;
      regacc_pst_ext_data_rd <= regacc_pst2_ext_data_rd;
      regacc_pst2_done       <= regacc_done;

      regacc_addr            <= regacc_pre2_addr;
      regacc_data_wr         <= regacc_pre2_data_wr;
      regacc_read            <= regacc_pre2_ext_read;
      regacc_write           <= regacc_pre2_ext_write;
      regacc_cnt             <= regacc_pre2_cnt;
      regacc_pst2_ext_data_rd <= regacc_data_rd;

      regacc_int_addr        <= regacc_pre_addr;
      regacc_int_data_wr     <= regacc_pre_data_wr;
      regacc_int_read        <= regacc_pre_int_read;
      regacc_int_write       <= regacc_pre_int_write;
      regacc_int_cnt         <= cnt;
      regacc_pst_int_data_rd <= regacc_int_data_rd;

      regacc_pst_done    <= (regacc_int_done  and     int_op) or
                            (regacc_pst2_done and not int_op);
    end if;
  end process;

  ram_cons_udp_regacc.clear_hasdata <= a.done;
  ram_prod_udp_regidp.set_hasdata <=
    a.done when (regacc_stat_aux.reg_idp = '1') else '0';
  ram_prod_udp_regidp.set_broadcast <= '0';
  ram_prod_udp_regidp.set_drop_dly  <= '0';
  ram_prod_udp_regidp.set_words <= ram_stat_udp_regacc.words;
  rpurr_set: for i in 0 to NUM_REG_CH-1 generate
    ram_prod_udp_regres(i).set_hasdata <=
      a.done when (regacc_stat_aux.reg_idp = '0' and
                   i = regacc_stat_aux.reg_ch) else '0';
    ram_prod_udp_regres(i).set_broadcast <= '0';
    ram_prod_udp_regres(i).set_drop_dly  <= '0';
    ram_prod_udp_regres(i).set_words <= ram_stat_udp_regacc.words;
  end generate;

  dp_ram_udp_regacc_porto.addr <= offp2(10 downto 1);
  dp_ram_udp_regacc_porto.rd <= not a.reset;
  w <= dp_ram_udp_regacc_porti.rdata;

  dp_ram_udp_regidp_porto.addr  <= actual_woff(10 downto 1);
  dp_ram_udp_regidp_porto.wdata <= actual_wdata;
  dp_ram_udp_regidp_porto.wr    <=
    actual_wr when (regacc_stat_aux.reg_idp = '1') else '0';
  dprurrpo_wr: for i in 0 to NUM_REG_CH-1 generate
    dp_ram_udp_regres_porto(i).addr  <= actual_woff(10 downto 1);
    dp_ram_udp_regres_porto(i).wdata <= actual_wdata;
    dp_ram_udp_regres_porto(i).wr    <=
      actual_wr when (regacc_stat_aux.reg_idp = '0' and
                      i = regacc_stat_aux.reg_ch) else '0';
  end generate;

  -- For debugging
  process (clk)
  begin
    if (rising_edge(clk)) then
      case s.state is
        when RSM_IDLE           => state_no <=     1;
        when RSM_FIRST          => state_no <=     2;
        when RSM_HEADER         => state_no <=     3;
        when RSM_NEXT_ACCESS    => state_no <=     4;
        when RSM_RADDR_1        => state_no <=     5;
        when RSM_RADDR_2        => state_no <=     6;
        when RSM_WRITE_RDATA_1  => state_no <=     7;
        when RSM_WRITE_RDATA_2  => state_no <=     8;
        when RSM_WRITE_WAIT     => state_no <=     9;
        when RSM_WRITE_WADDR_1  => state_no <=    10;
        when RSM_WRITE_WADDR_2  => state_no <=    11;
        when RSM_WRITE_WDATA_1  => state_no <=    12;
        when RSM_WRITE_WDATA_2  => state_no <=    13;
        when RSM_READ_WAIT      => state_no <=    14;
        when RSM_READ_WADDR_1   => state_no <=    15;
        when RSM_READ_WADDR_2   => state_no <=    16;
        when RSM_READ_WDATA_1   => state_no <=    17;
        when RSM_READ_WDATA_2   => state_no <=    18;
        when RSM_PAD            => state_no <=    19;
        when RSM_CK             => state_no <=    20;
        when RSM_DONE           => state_no <=    21;
      end case;
    end if;
  end process;

  debug_state <= std_logic_vector(to_unsigned(state_no,5));

end RTL;
