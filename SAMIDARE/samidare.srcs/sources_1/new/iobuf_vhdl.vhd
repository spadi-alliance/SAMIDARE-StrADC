----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/09/2024 01:33:47 PM
-- Design Name: 
-- Module Name: iobuf_vhdl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;
library work;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity iobuf_vhdl is
    Port ( io : inout STD_LOGIC;
           i : in STD_LOGIC;
           o : out STD_LOGIC;
           t : in STD_LOGIC);
end iobuf_vhdl;

architecture Behavioral of iobuf_vhdl is

begin

     scl_inst : IOBUF
       port map (
         IO         => io,
         I          => i,
         O          => o,
         T          => t);


end Behavioral;
