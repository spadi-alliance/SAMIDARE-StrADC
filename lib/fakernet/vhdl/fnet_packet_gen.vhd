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

use work.fnet_records.all;

use work.fnet_util_pkg.all;

entity fnet_packet_gen is
  port (clk          : in  std_logic;
        -- Config
        cfg_macaddr     : in  std_logic_vector (47 downto 0);
        cfg_ipaddr      : in  std_logic_vector (31 downto 0);
        --
        dyn_gen_stat    : out dync_gen_stat := dgs_zero;
        dyn_ctrl_stat   : in  dync_control_stat;
        ntpq_ctrl_stat  : in  ntpq_control_stat;
        mon_ctrl_stat   : in  mon_control_stat;
        --
        ram_stat_pkt_gen   : in ram_stat_block;
        ram_prod_pkt_gen   : out ram_prod_block;
        ram_cons_pkt_gen   : in  ram_cons_block;
        dp_ram_pkt_gen_porti : in  ram_block_porti_a11d16;
        dp_ram_pkt_gen_porto : out ram_block_porto_a11d16 := rbpo_zero

        );
end fnet_packet_gen;

architecture RTL of fnet_packet_gen is

  -- Size of command list.
  constant size  : integer := 2**8;

  -- Each sequencer command is stored in 32 bits.
  type cmd_array_type is array(0 to size-1) of std_logic_vector(31 downto 0);

  -- Each command consist of 32 bits.
  --
  -- A raw value (or multiplexer index or repeat count for 0)
  -- is stored in the high 16 bits.
  -- The low 16 bits contain flags, modifying the handling.
  --
  -- Handling of each command is pipelined in 3 stages.
  --
  -- In the first stage, the command is read from sequencer RAM.
  -- In the second stage, the value is prepared.
  -- In the third stage, the value is written to the output.
  --
  -- These operations use a predication strategy in order to only write
  -- results for cycles that correspond to a command that was read.
  --
  -- To easily generate several words with the value 0, a repeat count
  -- can be given instead of the data word.

  -- The most common item is a raw data word, with 16 bits in the low bits.
  --
  -- Then, data can be selected from two multiplexers.

  -- Multiplexer sources:

  constant MUX_MAC01     : natural := 0;
  constant MUX_MAC23     : natural := 1;
  constant MUX_MAC45     : natural := 2;
  constant MUX_IP01      : natural := 3;
  constant MUX_IP23      : natural := 4;
  constant MUX_IP_IDENT  : natural := 5;
  constant MUX_BOOTP_XID_H    : natural := 6;
  constant MUX_BOOTP_XID_L    : natural := 7;
  constant MUX_DHCP_XID_H     : natural := 8;
  constant MUX_DHCP_XID_L     : natural := 9;
  constant MUX_DHCP_REQ_IP01  : natural := 10;
  constant MUX_DHCP_REQ_IP23  : natural := 11;
  constant MUX_DHCP_SERV_IP01 : natural := 12;
  constant MUX_DHCP_SERV_IP23 : natural := 13;
  constant MUX_NTP_MAC01 : natural := 14;
  constant MUX_NTP_MAC23 : natural := 15;
  constant MUX_NTP_MAC45 : natural := 16;
  constant MUX_NTP_IP01  : natural := 17;
  constant MUX_NTP_IP23  : natural := 18;
  constant MUX_NTP_TM01  : natural := 19;
  constant MUX_NTP_TM23  : natural := 20;
  constant MUX_NTP_TM45  : natural := 21;
  constant MUX_NTP_TM67  : natural := 22;
  constant MUX_MON_MAC01 : natural := 23;
  constant MUX_MON_MAC23 : natural := 24;
  constant MUX_MON_MAC45 : natural := 25;
  constant MUX_MON_IP01  : natural := 26;
  constant MUX_MON_IP23  : natural := 27;
  constant MUX_MON_PORT  : natural := 28;

  -- Sequencer modification flags bits:

  constant BIT_MUX      : natural := 0; -- Choose from multiplexer.
  constant BIT_REPEAT   : natural := 1; -- Repeat (0) values.
  constant BIT_CHK_INIT : natural := 2; -- Initialise checksum.
  constant BIT_CHK_IPSD : natural := 3; -- Initialise checksum from pseudo.
  constant BIT_CHK_LOC  : natural := 4; -- Checksum location.
  constant BIT_CHK_WR   : natural := 5; -- Write checksum.
  constant BIT_PSD      : natural := 6; -- Part of pseudo-header for checksum.
  constant BIT_END      : natural := 7; -- Packet done, mark as ready.

  constant FLAG_MUX      : natural := 2 ** BIT_MUX;
  constant FLAG_CHK_INIT : natural := 2 ** BIT_CHK_INIT;
  constant FLAG_CHK_IPSD : natural := 2 ** BIT_CHK_IPSD;
  constant FLAG_CHK_LOC  : natural := 2 ** BIT_CHK_LOC;
  constant FLAG_CHK_WR   : natural := 2 ** BIT_CHK_WR;
  constant FLAG_PSD      : natural := 2 ** BIT_PSD;
  constant FLAG_REPEAT   : natural := 2 ** BIT_REPEAT;
  constant FLAG_END      : natural := 2 ** BIT_END;

  -- Repeat counts (for several 0 values in a row) are stored as the
  -- value.  The value stored is the repeat count - 3, such that a
  -- repeat of two values is signified by -1, and thus can be checked
  -- for in a lone high bit.  Note: the repeat count is for the number
  -- of 16-bit entries (2 octets).

  function rep (i : integer) return integer is
  begin
    if (i = 2) then
      return 2 ** 16 - 1;
    end if;
    return i - 3;
  end function;

  -- Utility function to express the sequencer commands compactly.

  function df (data : integer; flags : integer) return std_logic_vector is
    variable cmd : std_logic_vector(31 downto 0);
  begin
    cmd := i2slv16(data) & i2slv16(flags);
    return cmd;
  end function;

  -- The sequencer RAM.

  signal cmds : cmd_array_type := (
    -- =======================================================================
    -- RARP request packet.
    --  Ethernet header -----------
    df( 16#ffff#, 0           ), -- Dest MAC (broadcast).
    df( 16#ffff#, 0           ),
    df( 16#ffff#, 0           ),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#8035#, 0           ), -- RARP.
    --  RARP ----------------------
    df( 16#0001#, 0           ), -- Hardware type: ethernet (1).
    df( 16#0800#, 0           ), -- Protocol type: IPv4 (0x0800).
    df( 16#0604#, 0           ), -- Hardware size: 6, protocol size: 4.
    df( 16#0003#, 0           ), -- RARP request.
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df(   rep(2), FLAG_REPEAT ), -- Sender IP (0).
    df(MUX_MAC01, FLAG_MUX    ), -- Target (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( rep(2+9), FLAG_REPEAT ), -- Sender IP (0) + pad (60-42=18 octets).
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    -- BOOTP request packet.
    --  Ethernet header -----------
    df( 16#ffff#, 0           ), -- Dest MAC (broadcast).
    df( 16#ffff#, 0           ),
    df( 16#ffff#, 0           ),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#0800#, 0           ), -- IPv4.
    --  IPv4 header ---------------
    df( 16#4500#, FLAG_CHK_INIT), -- Version | IHL | DSCP | ECN.
    df( 16#0148#, FLAG_PSD + 0), -- Length.
    df(MUX_IP_IDENT, FLAG_MUX ), -- Seq. no.
    df( 16#4000#, 0           ), -- Flags (do not frag.).
    df( 16#4011#, 0           ), -- TTL | proto (UDP).
    df(        0, FLAG_CHK_LOC), -- Checksum.
    df(   rep(2), FLAG_PSD + FLAG_REPEAT ), -- Src IP hi & lo (0).
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP hi.
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP lo.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR), -- Write IP checksum.
    --  UDP header ----------------
    df( 16#0044#, FLAG_CHK_IPSD), -- Src port.
    df( 16#0043#, 0           ), -- Dest port.
    df( 16#0134#, 0           ), -- Length.
    df( 16#fffc#, FLAG_CHK_LOC), -- Checksum (value to fixup pseudo-checksum.)
    --                     -- (Corrects for protocol 0x11 and IP->UDP length.)
    --  BOOTP body. ---------------
    df( 16#0101#, 0           ), -- Opcode (1=request), hwtype (1=ethernet).
    df( 16#0600#, 0           ), -- HW len.
    df(MUX_BOOTP_XID_H, FLAG_MUX), -- Trans ID hi.
    df(MUX_BOOTP_XID_L, FLAG_MUX), -- Trans ID lo.
    df( 16#0000#, 0           ), -- Seconds.
    df( 16#0000#, 0           ), -- Flags.
    df(   rep(8), FLAG_REPEAT ), -- 4x IP: client, yours, next serv., gateway.
    df(MUX_MAC01, FLAG_MUX    ), -- Our MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df(rep(5+32+64), FLAG_REPEAT), -- MAC pad (10 octets),
    --                             -- server name (64 o), filename (128 o).
    df( 16#6382#, 0           ), -- DHCP magic hi. (vendor options)
    df( 16#5363#, 0           ), -- DHCP magic lo.
    df( 16#ff00#, 0           ), -- DHCP end option.
    df(rep(32-3), FLAG_REPEAT ), -- Vendor options pad.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR ), -- Write UDP checksum.
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    -- DHCP DISCOVER packet.
    --  Ethernet header -----------
    df( 16#ffff#, 0           ), -- Dest MAC (broadcast).
    df( 16#ffff#, 0           ),
    df( 16#ffff#, 0           ),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#0800#, 0           ), -- IPv4.
    --  IPv4 header ---------------
    df( 16#4500#, FLAG_CHK_INIT), -- Version | IHL | DSCP | ECN.
    df( 16#0148#, FLAG_PSD + 0), -- Length.
    df(MUX_IP_IDENT, FLAG_MUX ), -- Seq. no.
    df( 16#4000#, 0           ), -- Flags (do not frag.).
    df( 16#4011#, 0           ), -- TTL | proto (UDP).
    df(        0, FLAG_CHK_LOC), -- Checksum.
    df(   rep(2), FLAG_PSD + FLAG_REPEAT ), -- Src IP hi & lo (0).
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP hi.
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP lo.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR), -- Write IP checksum.
    --  UDP header ----------------
    df( 16#0044#, FLAG_CHK_IPSD), -- Src port.
    df( 16#0043#, 0           ), -- Dest port.
    df( 16#0134#, 0           ), -- Length.
    df( 16#fffc#, FLAG_CHK_LOC), -- Checksum (value to fixup pseudo-checksum.)
    --                     -- (Corrects for protocol 0x11 and IP->UDP length.)
    --  DHCP (BOOTP) body. --------
    df( 16#0101#, 0           ), -- Opcode (1=request), hwtype (1=ethernet).
    df( 16#0600#, 0           ), -- HW len.
    df(MUX_DHCP_XID_H, FLAG_MUX), -- Trans ID hi.
    df(MUX_DHCP_XID_L, FLAG_MUX), -- Trans ID lo.
    df( 16#0000#, 0           ), -- Seconds.
    df( 16#0000#, 0           ), -- Flags.
    df(   rep(8), FLAG_REPEAT ), -- 4x IP: client, yours, next serv., gateway.
    df(MUX_MAC01, FLAG_MUX    ), -- Our MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df(rep(5+32+64), FLAG_REPEAT), -- MAC pad (10 octets),
    --                             -- server name (64 o), filename (128 o).
    df( 16#6382#, 0           ), -- DHCP magic hi. (vendor options)
    df( 16#5363#, 0           ), -- DHCP magic lo.
    -- DHCP Option: 53(len 1) 1 (DHCP discover) + pad.
    df( 16#3501#, 0           ),
    df( 16#0100#, 0           ),
    -- DHCP Option: 51(len 4) (lease time: 258).
    -- Suggest (but more importantly request in list below) a lease time.
    -- Without it, a DHCP server GUI might not report the mapping.
    df( 16#3304#, 0           ),
    df( 16#0000#, 0           ),
    df( 16#0102#, 0           ),
    -- DHCP Option: 55(len 1) 1 (Param. req. list, 1: subnet mask, 51: lease).
    -- We do not use the subnet mask, just to request some parameter list.
    df( 16#3702#, 0           ),
    df( 16#0133#, 0           ),
    -- DHCP end option 255.
    df( 16#ff00#, 0           ), -- DHCP end option.
    df(rep(25-3), FLAG_REPEAT ), -- Vendor options pad.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR ), -- Write UDP checksum.
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    -- DHCP REQUEST packet.
    --  Ethernet header -----------
    df( 16#ffff#, 0           ), -- Dest MAC (broadcast).
    df( 16#ffff#, 0           ),
    df( 16#ffff#, 0           ),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#0800#, 0           ), -- IPv4.
    --  IPv4 header ---------------
    df( 16#4500#, FLAG_CHK_INIT), -- Version | IHL | DSCP | ECN.
    df( 16#0148#, FLAG_PSD + 0), -- Length.
    df(MUX_IP_IDENT, FLAG_MUX ), -- Seq. no.
    df( 16#4000#, 0           ), -- Flags (do not frag.).
    df( 16#4011#, 0           ), -- TTL | proto (UDP).
    df(        0, FLAG_CHK_LOC), -- Checksum.
    df(   rep(2), FLAG_PSD + FLAG_REPEAT ), -- Src IP hi & lo (0).
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP hi.
    df( 16#ffff#, FLAG_PSD + 0           ), -- Dest IP lo.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR), -- Write IP checksum.
    --  UDP header ----------------
    df( 16#0044#, FLAG_CHK_IPSD), -- Src port.
    df( 16#0043#, 0           ), -- Dest port.
    df( 16#0134#, 0           ), -- Length.
    df( 16#fffc#, FLAG_CHK_LOC), -- Checksum (value to fixup pseudo-checksum.)
    --                     -- (Corrects for protocol 0x11 and IP->UDP length.)
    --  DHCP (BOOTP) body. --------
    df( 16#0101#, 0           ), -- Opcode (1=request), hwtype (1=ethernet).
    df( 16#0600#, 0           ), -- HW len.
    df(MUX_DHCP_XID_H, FLAG_MUX), -- Trans ID hi.
    df(MUX_DHCP_XID_L, FLAG_MUX), -- Trans ID lo.
    df( 16#0000#, 0           ), -- Seconds.
    df( 16#0000#, 0           ), -- Flags.
    df(   rep(8), FLAG_REPEAT ), -- 4x IP: client, yours, next serv., gateway.
    df(MUX_MAC01, FLAG_MUX    ), -- Our MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df(rep(5+32+64), FLAG_REPEAT), -- MAC pad (10 octets),
    --                             -- server name (64 o), filename (128 o).
    df( 16#6382#, 0           ), -- DHCP magic hi. (vendor options)
    df( 16#5363#, 0           ), -- DHCP magic lo.
    -- DHCP Option: 53(len 1) 3 (DHCP request) + pad.
    df( 16#3501#, 0           ),
    df( 16#0300#, 0           ),
    -- DHCP Option: 51(len 4) (lease time: 258).
    df( 16#3304#, 0           ),
    df( 16#0000#, 0           ),
    df( 16#0102#, 0           ),
    -- DHCP Option: 55(len 1) 1 (Param. req. list, 1: subnet mask, 51: lease).
    -- We do not use the subnet mask, just to request a parameter list.
    df( 16#3702#, 0           ),
    df( 16#0133#, 0           ),
    -- DHCP Option: 50(len 4) (Requested IP address).
    df( 16#3204#, 0           ),
    df(MUX_DHCP_REQ_IP01, FLAG_MUX),
    df(MUX_DHCP_REQ_IP23, FLAG_MUX),
    -- DHCP Option: 54(len 4) (DHCP server IP address).
    df( 16#3604#, 0           ),
    df(MUX_DHCP_SERV_IP01, FLAG_MUX),
    df(MUX_DHCP_SERV_IP23, FLAG_MUX),
    -- DHCP end option 255.
    df( 16#ff00#, 0           ), -- DHCP end option.
    df(rep(19-3), FLAG_REPEAT ), -- Vendor options pad.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR ), -- Write UDP checksum.
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    -- NTP query.
    --  Ethernet header -----------
    df(MUX_NTP_MAC01, FLAG_MUX), -- Dest MAC.
    df(MUX_NTP_MAC23, FLAG_MUX),
    df(MUX_NTP_MAC45, FLAG_MUX),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#0800#, 0           ), -- IPv4.
    --  IPv4 header ---------------
    df( 16#4500#, FLAG_CHK_INIT), -- Version | IHL | DSCP | ECN.
    df( 16#004c#, FLAG_PSD + 0), -- Length.
    df(MUX_IP_IDENT, FLAG_MUX ), -- Seq. no.
    df( 16#4000#, 0           ), -- Flags (do not frag.).
    df( 16#4011#, 0           ), -- TTL | proto (UDP).
    df(        0, FLAG_CHK_LOC), -- Checksum.
    df(MUX_IP01 , FLAG_MUX + FLAG_PSD   ), -- Src IP.
    df(MUX_IP23 , FLAG_MUX + FLAG_PSD   ), -- Src IP.
    df(MUX_NTP_IP01, FLAG_MUX + FLAG_PSD), -- Dest IP.
    df(MUX_NTP_IP23, FLAG_MUX + FLAG_PSD), -- Dest IP.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR), -- Write IP checksum.
    --  UDP header ----------------
    df( 16#007b#, FLAG_CHK_IPSD), -- Src port (123).
    df( 16#007b#, 0           ), -- Dest port (123).
    df( 16#0038#, 0           ), -- Length.
    df( 16#fffc#, FLAG_CHK_LOC), -- Checksum (value to fixup pseudo-checksum.)
    --                     -- (Corrects for protocol 0x11 and IP->UDP length.)
    --  NTP body. -----------------
    df( 16#e30f#, 0           ), -- Flags: leap unknown 3, vers 4, client (3).
    --                           -- Stratum (15).
    df( 16#04ff#, 0           ), -- Poll (4, we lie), precision (-1).
    df(  rep(18), FLAG_REPEAT ), -- Root delay (4 o), disp (4 o),
    --                           -- ref id (4 o), ref value (8 o),
    --                           -- origin (8 o), receive (8 o).
    df(MUX_NTP_TM01, FLAG_MUX ), -- Transmit timestamp (msg identifier).
    df(MUX_NTP_TM23, FLAG_MUX ),
    df(MUX_NTP_TM45, FLAG_MUX ),
    df(MUX_NTP_TM67, FLAG_MUX ),
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR ), -- Write UDP checksum.
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    -- Monitor packet.
    --  Ethernet header -----------
    df(MUX_MON_MAC01, FLAG_MUX), -- Dest MAC.
    df(MUX_MON_MAC23, FLAG_MUX),
    df(MUX_MON_MAC45, FLAG_MUX),
    df(MUX_MAC01, FLAG_MUX    ), -- Sender (our) MAC.
    df(MUX_MAC23, FLAG_MUX    ),
    df(MUX_MAC45, FLAG_MUX    ),
    df( 16#0800#, 0           ), -- IPv4.
    --  IPv4 header ---------------
    df( 16#4500#, FLAG_CHK_INIT), -- Version | IHL | DSCP | ECN.
    df( 16#001c#, FLAG_PSD + 0), -- Length.
    df(MUX_IP_IDENT, FLAG_MUX ), -- Seq. no.
    df( 16#4000#, 0           ), -- Flags (do not frag.).
    df( 16#4011#, 0           ), -- TTL | proto (UDP).
    df(        0, FLAG_CHK_LOC), -- Checksum.
    df(MUX_IP01 , FLAG_MUX + FLAG_PSD   ), -- Src IP.
    df(MUX_IP23 , FLAG_MUX + FLAG_PSD   ), -- Src IP.
    df(MUX_MON_IP01, FLAG_MUX + FLAG_PSD), -- Dest IP.
    df(MUX_MON_IP23, FLAG_MUX + FLAG_PSD), -- Dest IP.
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR), -- Write IP checksum.
    --  UDP header ----------------
    df( 16#0020#, FLAG_CHK_IPSD), -- Src port (32).
    df(MUX_MON_PORT, FLAG_MUX ), -- Dest port.
    df( 16#0008#, 0           ), -- Length.
    df( 16#fffc#, FLAG_CHK_LOC), -- Checksum (value to fixup pseudo-checksum.)
    --                     -- (Corrects for protocol 0x11 and IP->UDP length.)
    --  Monitor body. -------------
    df(   rep(3), FLAG_REPEAT + FLAG_CHK_WR ), -- Write UDP checksum.
    df(        0, FLAG_END    ), -- Data not written.
    -- =======================================================================
    others => (others => '0')
    );

  constant cmdn_RARP      : natural := 7+13;
  constant cmdn_BOOTP     : natural := 7+10+4+11+6;
  constant cmdn_DHCP_DISC : natural := 7+10+4+11+2+2+3+2+4;
  constant cmdn_DHCP_REQ  : natural := 7+10+4+11+2+2+3+2+3+3+4;
  constant cmdn_NTP_QUERY : natural := 7+11+4+9;
  constant cmdn_MON       : natural := 7+11+4+2;

  constant cmdi_RARP      : natural := 0;
  constant cmdi_BOOTP     : natural := cmdi_RARP      + cmdn_RARP;
  constant cmdi_DHCP_DISC : natural := cmdi_BOOTP     + cmdn_BOOTP;
  constant cmdi_DHCP_REQ  : natural := cmdi_DHCP_DISC + cmdn_DHCP_DISC;
  constant cmdi_NTP_QUERY : natural := cmdi_DHCP_REQ  + cmdn_DHCP_REQ;
  constant cmdi_MON       : natural := cmdi_NTP_QUERY + cmdn_NTP_QUERY;
  constant cmdi_NEXTFREE  : natural := cmdi_MON       + cmdn_MON;

  -- For all variables, p0 means value in first pipeline stage.
  -- p1 is value in second pipeline stage and p2 is value in third
  -- pipeline stage.  For asynchronous statements, LHS and RHS should
  -- be in the same stage.  For clocked assignments, RHS should be
  -- one stage earlier.

  -- The command address to read.
  signal cmdi_p0 : unsigned(8 downto 0) := to_unsigned(0,9);

  -- The command read from memory (p1), and in third stage.
  signal cmd_p1 : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd_p2 : std_logic_vector(31 downto 0) := (others => '0');

  -- Is the pipeline stage active?
  signal active_p0 : std_logic := '0';
  signal active_p1 : std_logic := '0';
  signal active_p2 : std_logic := '0';

  -- NTP query needs to be signalled at end of transmission, so
  -- keep track of both generation and then transmission.
  signal active_ntp_query : std_logic := '0';
  signal sending_ntp_query : std_logic := '0';
  signal sent_ntp_query : std_logic := '0';

  -- Are we repeating values.
  signal repeating_p1 : std_logic := '0';

  -- Was a (new) command read.
  -- (Will not be set when no read due to repeat).
  signal read_cmd_p1 : std_logic := '0';

  -- First repeat (from freshly read command).
  signal first_repeat_p1 : std_logic := '0';

  -- Number of repeat values to do.
  signal repeat_cnt : unsigned(8 downto 0) := (others => '0');

  -- Value from multiplexer.
  signal mux_value_p2 : std_logic_vector(15 downto 0) := (others => '0');

  type mux_array_type is array(0 to 31) of std_logic_vector(15 downto 0);

  -- Multiplexer of dynamic values.
  signal mux : mux_array_type := (others => (others => '0'));

  -- Raw value from command (or 0 if repeat).
  signal value_p2 : std_logic_vector(15 downto 0) := (others => '0');

  -- Actual value to use (raw, 0 or multiplexer).
  signal use_p2 : std_logic_vector(15 downto 0) := (others => '0');

  -- First word, such that offset should be restarted?
  signal reset_offset_p0 : std_logic := '0';
  -- The output offset.
  signal offset_p1 : unsigned(9 downto 0) := (others => '0');
  signal offset_p2 : unsigned(9 downto 0) := (others => '0');

  -- Offset of checksum value.
  signal offset_cksum : unsigned(9 downto 0) := (others => '0');

  -- Checksum.
  signal cksum : unsigned(16 downto 0) := (others => '0');
  signal fold_cksum : unsigned(16 downto 0) := (others => '0');

  -- IP pseudo-header checksum (for UDP/TCP).
  signal pseudo_cksum : unsigned(16 downto 0) := (others => '0');
  signal fold_pseudo_cksum : unsigned(16 downto 0) := (others => '0');

  -- Checksum to write.
  signal wr_cksum : std_logic_vector(15 downto 0) := (others => '0');

  -- Packet count (for identification word).
  signal packet_count : unsigned(7 downto 0) := (others => '0');

begin

  -- Assignments of dynamic (multiplexer) values.
  mux(MUX_MAC01) <= cfg_macaddr(47 downto 32);
  mux(MUX_MAC23) <= cfg_macaddr(31 downto 16);
  mux(MUX_MAC45) <= cfg_macaddr(15 downto  0);
  mux(MUX_IP01) <= cfg_ipaddr(31 downto 16);
  mux(MUX_IP23) <= cfg_ipaddr(15 downto  0);
  mux(MUX_BOOTP_XID_H) <= dyn_ctrl_stat.bootp_xid(31 downto 16);
  mux(MUX_BOOTP_XID_L) <= dyn_ctrl_stat.bootp_xid(15 downto  0);
  mux(MUX_DHCP_XID_H)  <= dyn_ctrl_stat.dhcp_xid(31 downto 16);
  mux(MUX_DHCP_XID_L)  <= dyn_ctrl_stat.dhcp_xid(15 downto  0);
  mux(MUX_DHCP_REQ_IP01)  <= dyn_ctrl_stat.dhcp_offer_ip(31 downto 16);
  mux(MUX_DHCP_REQ_IP23)  <= dyn_ctrl_stat.dhcp_offer_ip(15 downto  0);
  mux(MUX_DHCP_SERV_IP01) <= dyn_ctrl_stat.dhcp_offer_serv_ip(31 downto 16);
  mux(MUX_DHCP_SERV_IP23) <= dyn_ctrl_stat.dhcp_offer_serv_ip(15 downto  0);
  mux(MUX_NTP_MAC01) <= ntpq_ctrl_stat.ntpq_mac(47 downto 32);
  mux(MUX_NTP_MAC23) <= ntpq_ctrl_stat.ntpq_mac(31 downto 16);
  mux(MUX_NTP_MAC45) <= ntpq_ctrl_stat.ntpq_mac(15 downto  0);
  mux(MUX_NTP_IP01)  <= ntpq_ctrl_stat.ntpq_ip(31 downto 16);
  mux(MUX_NTP_IP23)  <= ntpq_ctrl_stat.ntpq_ip(15 downto  0);
  mux(MUX_NTP_TM01)  <= ntpq_ctrl_stat.ntpq_tm(63 downto 48);
  mux(MUX_NTP_TM23)  <= ntpq_ctrl_stat.ntpq_tm(47 downto 32);
  mux(MUX_NTP_TM45)  <= ntpq_ctrl_stat.ntpq_tm(31 downto 16);
  mux(MUX_NTP_TM67)  <= ntpq_ctrl_stat.ntpq_tm(15 downto  0);
  mux(MUX_IP_IDENT)  <= "00000000" & std_logic_vector(packet_count);
  mux(MUX_MON_MAC01) <= mon_ctrl_stat.mon_mac(47 downto 32);
  mux(MUX_MON_MAC23) <= mon_ctrl_stat.mon_mac(31 downto 16);
  mux(MUX_MON_MAC45) <= mon_ctrl_stat.mon_mac(15 downto  0);
  mux(MUX_MON_IP01)  <= mon_ctrl_stat.mon_ip(31 downto 16);
  mux(MUX_MON_IP23)  <= mon_ctrl_stat.mon_ip(15 downto  0);
  mux(MUX_MON_PORT)  <= mon_ctrl_stat.mon_port;

  -- The first cycle doing a repeat is found directly from the command.
  -- (And the command has to be freshly read.)
  first_repeat_p1 <= cmd_p1(BIT_REPEAT) and read_cmd_p1;

  process (clk)
  begin
    if (rising_edge(clk)) then

      dyn_gen_stat <= dgs_zero;
      
      -- Default value.
      reset_offset_p0 <= '0';

      -- Should we start?
      if (ram_stat_pkt_gen.hasdata = '0' and
          active_p0 = '0' and active_p1 = '0' and active_p2 = '0') then
        if (dyn_ctrl_stat.pending_rarp = '1') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_RARP, cmdi_p0'length);
          dyn_gen_stat.gen_rarp <= '1';
        elsif (dyn_ctrl_stat.pending_bootp = '1') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_BOOTP, cmdi_p0'length);
          dyn_gen_stat.gen_bootp <= '1';
        elsif (dyn_ctrl_stat.pending_dhcp_disc = '1') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_DHCP_DISC, cmdi_p0'length);
          dyn_gen_stat.gen_dhcp_disc <= '1';
        elsif (dyn_ctrl_stat.pending_dhcp_req = '1') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_DHCP_REQ, cmdi_p0'length);
          dyn_gen_stat.gen_dhcp_req <= '1';
        elsif (ntpq_ctrl_stat.pending_ntp_query = '1' and
               -- One extra cycle delay of inhibit, since it takes
               -- another cycle to remove the request.
               sent_ntp_query = '0') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_NTP_QUERY, cmdi_p0'length);
          active_ntp_query <= '1';
        elsif (mon_ctrl_stat.pending_mon = '1') then
          active_p0 <= '1';
          reset_offset_p0 <= '1';
          cmdi_p0 <= to_unsigned(cmdi_MON, cmdi_p0'length);
          dyn_gen_stat.gen_mon <= '1';
        end if;
      end if;

      -- Default value.
      read_cmd_p1 <= '0';
      -- Read command (unless we are repeating).
      if (active_p0 = '1' and
          repeating_p1 = '0' and
          first_repeat_p1 = '0') then
        cmd_p1 <= cmds(to_integer(cmdi_p0));
        read_cmd_p1 <= '1';
      end if;

      if (active_p0 = '1' and
          repeating_p1 = '0' and
          first_repeat_p1 = '0') then
        -- If we are not repeating, then increment the command pointer.
        cmdi_p0 <= cmdi_p0 + 1;
      end if;

      -- Pipeline.
      active_p1 <= active_p0;

      if (cmd_p1(BIT_END) = '1') then
        active_p0 <= '0';
        active_p1 <= '0';
        -- Keep track of the packet that will now be sent is a NTP query.
        sending_ntp_query <= active_ntp_query;
        active_ntp_query <= '0';
      end if;

      packet_count <= packet_count + ("" & cmd_p1(BIT_END));

      sent_ntp_query <= '0';
      -- Since the output RAM only holds one packet, when it is
      -- cleared, the packet that was generated has been sent.
      if (ram_cons_pkt_gen.clear_hasdata = '1') then
        -- Signal NTP query generation at end of packet.
        -- This such that the recorded timestamp (sent in monitoring)
        -- is related to the actual end-of-transmission.
        sent_ntp_query <= '1';
        sending_ntp_query <= '0';
        dyn_gen_stat.gen_ntp_query <= sending_ntp_query;
      end if;

      -- Only start repeat if we are not repeating.
      if (repeating_p1 = '0' and
          first_repeat_p1 = '1') then
        -- If initial repeat count is -1, then actual count is 2, and
        -- that we will repeat by just the immediate repeat from
        -- checking cmd_p1(BIT_REPEAT).
        if (cmd_p1(16+9) /= '1') then
          repeating_p1 <= '1';
        end if;
        repeat_cnt <= unsigned(cmd_p1(16+8 downto 16));
      end if;

      -- If repeating, consider stopping and decrement the count.
      if (repeating_p1 = '1') then
        if (repeat_cnt = 0) then
          repeating_p1 <= '0';
        end if;
        repeat_cnt <= repeat_cnt - 1;
      end if;

      -- Offset handling.  Moves forward unless we are writing a checksum.
      if (reset_offset_p0 = '1') then
        offset_p1 <= (others => '0');
      else
        if (cmd_p1(BIT_CHK_WR) = '0') then
          offset_p1 <= offset_p1 + 1;
        end if;
      end if;

      -- Pass offset along
      offset_p2 <= offset_p1;

      -- Choose value from multiplexer.
      mux_value_p2 <= mux(to_integer(unsigned(cmd_p1(16+4 downto 16+0))));

      -- Value in next cycle is by default the direct value.
      value_p2 <= cmd_p1(31 downto 16);

      if (cmd_p1(BIT_REPEAT) = '1') then
        -- Actual value is 0 when repeating.
        value_p2 <= (others => '0');
        -- value_p2 <= "0101010101010101";
      end if;

      -- Pass the cmd along to the next cycle.
      cmd_p2    <= cmd_p1;
      active_p2 <= active_p1;

      if (cmd_p2(BIT_CHK_INIT) = '1') then
        pseudo_cksum <= (others => '0');
      elsif (cmd_p2(BIT_PSD) = '1') then
        pseudo_cksum <= fold_pseudo_cksum +
                        unsigned(use_p2);
      end if;

      -- Update (or init) checksum.
      if (cmd_p2(BIT_CHK_INIT) = '1') then
        cksum <= "0" & unsigned(use_p2);
      elsif (cmd_p2(BIT_CHK_IPSD) = '1') then
        cksum <= pseudo_cksum + unsigned(use_p2);
      else
        cksum <= fold_cksum +
                 unsigned(use_p2);
      end if;

      -- Remember checksum destination.
      if (cmd_p2(BIT_CHK_LOC) = '1') then
        offset_cksum <= offset_p2;
      end if;

    end if;
  end process;

  -- Precalc cksum.
  fold_cksum <=
    ('0' & cksum(15 downto 0)) + ("" & cksum(16));
  fold_pseudo_cksum <=
    ('0' & pseudo_cksum(15 downto 0)) + ("" & pseudo_cksum(16));

  -- Since a write of the checksum contain two additional repeat stages
  -- (which add the implicit value 0), the final checksum will be
  -- folded twice, which is the maximum need to remove all overflows.
  wr_cksum <= not std_logic_vector(cksum(15 downto 0));

  -- We use the multiplexer value when directed to do so, otherwise
  -- the direct value (or however it was calculated).
  use_p2 <=
    value_p2 when (cmd_p2(BIT_MUX) = '0') else
    mux_value_p2;

  -- The write to the output RAM:
  dp_ram_pkt_gen_porto.addr  <=
    std_logic_vector(offset_cksum) when (cmd_p2(BIT_CHK_WR) = '1') else
    std_logic_vector(offset_p2);

  -- Write the value or the checksum.
  dp_ram_pkt_gen_porto.wdata <=
    wr_cksum when (cmd_p2(BIT_CHK_WR) = '1') else
    use_p2;

  -- Write when active.
  dp_ram_pkt_gen_porto.wr <= active_p2;

  -- We flag data as available when writing last word.
  ram_prod_pkt_gen.set_hasdata   <= cmd_p2(BIT_END) and active_p2;
  ram_prod_pkt_gen.set_broadcast <= '0';
  ram_prod_pkt_gen.set_drop_dly  <= '0';

  -- Number of output words is taken from the second pipe stage.
  ram_prod_pkt_gen.set_words <= std_logic_vector(offset_p1 & '0');

end RTL;
