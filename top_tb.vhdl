----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.12.2025 16:03:53
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
signal clk          :   std_logic;
signal reset        :   std_logic;
--signal slow_en	:	std_logic;
signal floor_req    :   std_logic_vector(3 downto 0);
signal move_up      :   std_logic;
signal move_down    :   std_logic;
signal open_door    :   std_logic;
signal floor        :   std_logic_vector(3 downto 0);
--signal f_o          :   std_logic_vector(3 downto 0);
signal led          :   std_logic;



signal req_history	:	std_logic_vector(3 downto 0) := (others => '0');
signal served		:	std_logic_vector(3 downto 0) := (others => '0');

begin
    top : entity work.top
        port map(
            clk             =>   clk,
            reset           =>   reset,
	--		slow_clk		=>	 slow_clk,
            floor_request   =>   floor_req,
            move_up         =>   move_up,
            move_down       =>   move_down,
            open_door       =>   open_door,
            floor           =>   floor,
	    led             =>   led
        );
        
    clk_process : process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;
    
    reset <= '1','0' after 15 ns;      
    
    stimuli : process
begin
  -- initial state
  floor_req <= "0000";

  -- wait for reset
  wait until reset = '0';
  wait for 20 ns;

  ----------------------------------------------------------------
  -- Issues overlapping requests
  ----------------------------------------------------------------
  floor_req <= "1000"; -- floor 3
  req_history  <= req_history or "1000";
  
  
  wait for 50 ns;
  floor_req <= "0010";  -- floor 1
  req_history   <= req_history or "0010";
  

  wait for 50 ns;
  floor_req <= "0100";  -- floor 2
  req_history   <= req_history or "0100";
  
  
  wait for 1000 ns;
  floor_req <= "0010"; -- floor 1
  req_history	<= req_history or "0010";
  
  
  wait for 1000 ns;
  floor_req <= "1000"; -- floor 3
  req_history	<= req_history or "1000";
  
  
  wait for 50 ns;
  floor_req <= "0001"; -- floor 0
  req_history	<= req_history or "0001";
  

  -- release buttons
  wait for 20 ns;
  floor_req <= "0000";
  
  wait;
end process;

 ------------------------------------------------------------------
  -- Stop checker
  ------------------------------------------------------------------
  checker : process
	variable f : integer;
	begin
	--wait until the first door opening
	wait until reset = '0';
	wait until open_door'event and open_door = '1';
	
	while true loop
	
		f := to_integer(unsigned(floor));
		
		--Check that if stop was expected
		--Must have requested sometime earlier
		assert req_history(f) = '1'
		report "Unexpected stop at floor" & integer'image(f)
		severity error;
		
		--report "Stopped at floor" & integer'image(f)
			--severity note;
		
		--Must not be served twice
		
		assert served(f) = '0'
		report "Duplicate stop at floor " & integer'image(f)
		severity error;
		
		report "Stopped at valid floor " & integer'image(f)
		severity note;
		
		--mark as served
		served(f) <= '1';
		--wait for door close before next Stop
		
		wait until open_door = '0';
		wait until open_door'event and open_door = '1';
	end loop;
	
	report "All requests served"
		severity note;
	wait;
  end process;
     
end Behavioral;
