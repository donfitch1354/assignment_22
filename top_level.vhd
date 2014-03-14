----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:47:39 03/13/2014 
-- Design Name: 
-- Module Name:    top_level - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    Port ( 	clk : in  STD_LOGIC;
				reset : in std_logic;
				switch : in STD_LOGIC_VECTOR (7 downto 0);
				btn: in std_logic_vector (3 downto 0);
				led: out std_logic_vector (7 downto 0)
				);
end top_level;

architecture Behavioral of top_level is
component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;

--
-- Declaration of the default Program Memory recommended for development.
--
-- The name of this component should match the name of your PSM file.
--

  component custom_ROM                            
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;



	signal         address : std_logic_vector(11 downto 0);
	signal     instruction : std_logic_vector(17 downto 0);
	signal     bram_enable : std_logic;
	signal         in_port : std_logic_vector(7 downto 0);
	signal        out_port : std_logic_vector(7 downto 0);
	signal         port_id : std_logic_vector(7 downto 0);
	signal    write_strobe : std_logic;
	signal  k_write_strobe : std_logic;
	signal     read_strobe : std_logic;
	signal       interrupt : std_logic;
	signal   interrupt_ack : std_logic;
	signal    kcpsm6_sleep : std_logic;
	signal    kcpsm6_reset : std_logic;
	signal       cpu_reset : std_logic;
	signal             rdl : std_logic;

--
-- When interrupt is to be used then the recommended circuit included below requires 
-- the following signal to represent the request made from your system.
--

	signal     int_request : std_logic;

begin

	processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
 
 
   program_rom: custom_ROM                   	--Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);


	in_port <= 	switch(7 downto 0)	when port_id = x"AF" else
					"0000" & btn(3 downto 0) 		when port_id = x"BC" else
					(others => '0');
					
	process(clk)
	begin
		if rising_edge(clk) then
			if port_id = x"07" and write_strobe = '1' then
				led <= out_port;
			end if;
		end if;
	end process;

end Behavioral;

