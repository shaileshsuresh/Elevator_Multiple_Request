----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.12.2025 19:47:41
-- Design Name: 
-- Module Name: clock_divider - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_enable_gen is
  generic (
	MAX_COUNT	:	integer := 10
  );
	
  Port (
    clk     	:   in std_logic;
    reset   	:   in std_logic;
    slow_en    :   out std_logic    
   );
end clock_enable_gen;

architecture Behavioral of clock_enable_gen is

signal count    :   integer range 0 to MAX_COUNT-1;
signal c_out    :   std_logic;
begin

    process(clk)
    begin
		if rising_edge(clk) then
			if reset = '1' then
				c_out <= '0';
				count <= 0;
			elsif count = MAX_COUNT-1 then
                count <= 0;
                c_out <= '1';
            else
                count <= count + 1;
				c_out <= '0';
            end if;
        end if;
    end process;
    
    slow_en <= c_out;
 

end Behavioral;

