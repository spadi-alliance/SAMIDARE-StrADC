library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

-- Sampling using an Xilinx ISERDESE2

entity rataser_4phase_sample is
  generic (max_skew   : string := "unused");
  port (clk           : in std_logic;
        clk90         : in std_logic;
        serial_in     : in std_logic;

        -- Sample at 0, 90, 180 and 270 degrees, cycles 2 and 3.
        saz           : out std_logic_vector(2 to 3);
        sbz           : out std_logic_vector(2 to 3);
        scz           : out std_logic_vector(2 to 3);
        sdz           : out std_logic_vector(2 to 3)
  );
  
end rataser_4phase_sample;

architecture RTL of rataser_4phase_sample is

  signal clk_n : std_logic;
  signal clk90_n : std_logic;
  
  signal i_saz : std_logic_vector(0 to 1) := (others => '0');
  signal i_sbz : std_logic_vector(0 to 1) := (others => '0');
  signal i_scz : std_logic_vector(0 to 1) := (others => '0');
  signal i_sdz : std_logic_vector(0 to 1) := (others => '0');

begin

  clk_n <= not clk;
  clk90_n <= not clk90;

  -- Xz(0) is the first sample point, a-d are at progressively 90 degrees
  -- later phase of the clock cycle.
  --
  -- Xz(1) is the previous sample.

  process(clk)
  begin
    if (rising_edge(clk)) then
      -- x(0) is sampled by the iserdes below
      i_saz(1) <= i_saz(0);
      i_sbz(1) <= i_sbz(0);
      i_scz(1) <= i_scz(0);
      i_sdz(1) <= i_sdz(0);
    end if;
  end process;
  
  saz <= i_saz;
  sbz <= i_sbz;
  scz <= i_scz;
  sdz <= i_sdz;

  -- Using ISERDESE2 for oversampling is described in UG471 page 154.
  SERDES : ISERDESE2
    generic map (
      INTERFACE_TYPE      => "OVERSAMPLE",
      DATA_RATE           => "DDR", 
      DATA_WIDTH          => 4, 
      OFB_USED            => "FALSE",
      NUM_CE              => 1,
      SERDES_MODE         => "MASTER",
      IOBDELAY            => "NONE",
      DYN_CLKDIV_INV_EN   => "FALSE",
      DYN_CLK_INV_EN      => "FALSE",
      INIT_Q1             => '1',
      INIT_Q2             => '1',
      INIT_Q3             => '1',
      INIT_Q4             => '1',
      SRVAL_Q1            => '0',
      SRVAL_Q2            => '1',
      SRVAL_Q3            => '0',
      SRVAL_Q4            => '0'
      )
    port map (
      CLK             => clk,
      CLKB            => clk_n,
      OCLK            => clk90,
      OCLKB           => clk90_n,
      D               => serial_in,
      BITSLIP         => '0',
      CE1             => '1',
      CE2             => '1',
      CLKDIV          => '0',
      CLKDIVP         => '0',
      DDLY            => '0',
      DYNCLKDIVSEL    => '0',
      DYNCLKSEL       => '0',
      OFB             => '0',
      RST             => '0',
      SHIFTIN1        => '0',
      SHIFTIN2        => '0',
      O               => open,
      -- UG471 fig. 3-7.
      -- Q1 = sample 1, Q2 = sample 3, Q3 = sample 2, Q4 = sample 4
      Q1              => i_saz(0), 
      Q2              => i_scz(0),
      Q3              => i_sbz(0),
      Q4              => i_sdz(0),            
      Q5              => open,
      Q6              => open,
      Q7              => open,
      Q8              => open,
      SHIFTOUT1       => open,
      SHIFTOUT2       => open
      );  
  
end RTL;  
