# Fakernet


Introduction
============

This repository is for the implementation of Fakernet on different FPGA boards.
For Fakernet, the details can be obtained from https://fy.chalmers.se/~f96hajo/fakernet/
The driver software should be also downloaded from the webpage. 


File list
=========

`lib/`: Source codes of Fakernet. Common for all the boards. Some of the codes have been modified and simplified from the original version.

`Belle2_UT4_1G`: Example firmware of the Belle II UT4 board (Virtex UltraScale). Using GTY with pcs/pma IPcore, 1000Base-X.

`Belle2_UT4_2.5G`: Example firmware of the Belle II UT4 board (Virtex UltraScale). Using GTY with pcs/pma IPcore, 2500Base-X.

`nexys_video`: Example firmware of the Nexys Video card (Artix-7). Using Realtek RTL8211E-VL PHY. The firmware is made for 1G.

`HUL`: Example firmware of the Hadron Universal Logic module (Kintex-7). Using LAN8810-AKZE PHY. The firmware is made for 1G.

`SAMIDARE`: Example firmware of the SAMIDARE. Using GTH with pcs/pma IPcore, 1000Base-X.

`AMANEQ`: Example firmware of the AMANEQ. Using GTX with pcs/pma IPcore, 1000Base-X.

For the file downloaded from the Fakernet's original webpage, there are also the exmaples of Arty A7-35 board and Alinx AX516 board.


Notice
======

1. IP address is fixed as `192.168.1.192` as written in `lib/fakernet/fakernet_top.vhd`, line 133:
```
  -- c0a801c0 = 192.168.1.192
  signal ipaddr  : std_logic_vector(31 downto 0) :=
    "11000000" & "10101000" & "00000001" & "11000000";
```
It can be connected to a dip switch or modified freely.

2. In the top-level of firmware, the inst of `lib/fakernet/fakernet_top.vhd`, the `clk_in` port: 
Connect a free-running 125 MHz clock to it in the case of 1G
Connect the gmii_clk (312.5MHz) to it in the case of 1G
Similarly, the inst of data generator, the same clock should be connected.


Test
====

After downloading the original source, enter the `client` folder and do `make` to compile it.
When the FGPA is programmed and connected to the NIC of your PC, set up the IPv4 IP as an arbitrary one, and netmask as 255.255.255.0.

1. Quick check:
```
ping 192.168.1.192
./fnetctrl 192.168.1.192 --stat
```

2. TCP data throughput check:
```
./fnetctrl 192.168.1.192 --tcp-lcl-datagen=1
./fnetctrl 192.168.1.192 --tcp-lcl-data-chance=100000000
./fnetctrl 192.168.1.192 --tcp-lcl-data-valmask=8191
./fnetctrl 192.168.1.192 --tcp=local
```
For 1G, it should be around 117000 kB/s.

3. TCP with user data generator:
```
./fnetctrl 192.168.1.192 --write=0x05:3
./fnetctrl 192.168.1.192 --tcp-lcl-datagen=0
./fnetctrl 192.168.1.192 --tcp
```
For 1G, it should be around 27300 kB/s.
You can refer to `lib/fakernet/data_gen_user.vhd` to see how the data frame is made and sent to Fakernet.

