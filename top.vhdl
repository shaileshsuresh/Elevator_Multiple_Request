----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.12.2025 19:47:41
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
  Port (
    clk             :   in std_logic;
    reset           :   in std_logic;
	--slow_clk		:	in std_logic;
    floor_request   :   in std_logic_vector(3 downto 0);
    move_up         :   out std_logic;
    move_down       :   out std_logic;
    open_door       :   out std_logic;
    floor           :   out std_logic_vector(3 downto 0);
 --   f_o             :   out std_logic_vector(3 downto 0);
    led             :   out std_logic    
   );
end top;

architecture Behavioral of top is

signal slow_en   	:   std_logic;
signal sig_move_up	:   std_logic;
signal sig_move_down	:   std_logic;
signal sig_open_door	:   std_logic;
begin

    move_up		<=	 sig_move_up;
    move_down		<=	 sig_move_down;
    open_door		<=	 sig_open_door;

    led <= sig_move_up or sig_move_down;
    clk_div : entity work.clock_enable_gen
        port map(
            clk         => clk,
            reset       => reset,
            slow_en     => slow_en
         );
         
    lift : entity work.lift
        port map(
            clk        =>   clk,
            reset      =>   reset,
			slow_en	   =>   slow_en,
            floor_req  =>   floor_request,
            move_up    =>   sig_move_up,
            move_down  =>   sig_move_down,
            open_door  =>   sig_open_door,
            floor      =>   floor
          --  f_o        =>   f_o
         
        );

end Behavioral;
