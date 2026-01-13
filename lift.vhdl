----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.12.2025 19:47:41
-- Design Name: 
-- Module Name: lift - Behavioral
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

entity lift is
  Port (
    clk        :    in std_logic;
    reset      :    in std_logic;
    slow_en    :    in std_logic;
    floor_req  :    in std_logic_vector(3 downto 0);
    move_up    :    out std_logic;
    move_down  :    out std_logic;
    open_door  :    out std_logic;
    floor      :    out std_logic_vector(3 downto 0)
   );
end lift;

architecture Behavioral of lift is

type state_t is (idle,moving_up,moving_down,door);
type dir is (up,down);

constant DOOR_TIMER : integer:= 5;

signal state        :   state_t;
signal next_state   :   state_t;
signal last_dir		: 	dir := up;
signal current_floor:   integer range 0 to 3 := 0;
signal target_floor	:	integer range 0 to 3 := 0;
signal door_cnt	    :	integer range 0 to DOOR_TIMER := 0;
signal pending_req	:	std_logic_vector(3 downto 0) := (others => '0');

signal req_above	:	std_logic;
signal req_below	:	std_logic;


begin
			
   --Target floor register-- 
   
	process(state, pending_req, current_floor)
	begin
		--default: stay where you are
		target_floor <= current_floor;
		case state is
			when idle =>
				--prefer requests above
				for i in 0 to 3 loop
				  if i > current_floor then
					if pending_req(i) = '1' then
						target_floor <= i;
						exit;
				    end if;
				  end if;
				end loop;
				
				--if none above, look below
				if target_floor = current_floor then
					for i in 3 downto 0 loop
                      if i < current_floor then					   
						if pending_req(i) = '1' then
							target_floor <= i;
							exit;
						end if;
					  end if;
					end loop;
				end if;
				
			when moving_up =>
				for i in 0 to 3 loop
				  if i > current_floor then
					if pending_req(i) = '1' then
						target_floor <= i;
						exit;
					end if;
				  end if;
				end loop;
				
			--moving down -> look only below
			
			when moving_down =>
				for i in 3 downto 0 loop
				  if i < current_floor then
					if pending_req(i) = '1' then
						target_floor <= i;
						exit;
					end if;
				  end if;
				end loop;
			
			when others =>
				null;
			
			end case;
	end process;
				
	--State transition logic--
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= idle;
				last_dir <= up;
			else
				state <= next_state;
				if state = moving_up then
					last_dir <= up;
				elsif state = moving_down then
					last_dir <= down;
				end if;
			end if;
		end if;
	end process;
	
	--Door timer logic --
	
	process(clk)
	begin
    if rising_edge(clk) then
        if reset = '1' then
            door_cnt <= 0;

        elsif state = door then
            if slow_en = '1' then
                if door_cnt < DOOR_TIMER then
                    door_cnt <= door_cnt + 1;
                end if;
            end if;

        else
            door_cnt <= 0;  -- reset timer when not in door
        end if;
    end if;
end process;
	
	--Pending Request process--
	
	process(clk)
	variable next_pending : std_logic_vector(3 downto 0);
	begin
		if rising_edge(clk) then
			if reset = '1' then
				pending_req <= (others => '0');
				
			else
			--capture requests at any time
				next_pending := pending_req or floor_req;
				if state = door then
					next_pending(current_floor) := '0';
				end if;
				
				pending_req <= next_pending;
			end if;
		end if;
	end process;
	
	
	--Block for helper signals
	
	process(pending_req, current_floor)
	begin
		req_above <= '0';
		req_below <= '0';
		
		--check floors above
		
		for i in 0 to 3 loop
		  if i > current_floor then
			if pending_req(i) = '1' then
				req_above <= '1';
				exit;
			end if;
		  end if;
		end loop;
		
		--check floors below
		
		for i in 3 downto 0 loop
		  if i < current_floor then
			if pending_req(i) = '1' then
				req_below <= '1';
				exit;
			end if;
		  end if;
		end loop;	
	end process;
	
	
	--FSM combinational logic--
	
	process(state, current_floor, target_floor, req_above, req_below, pending_req, door_cnt)
	begin
		next_state <= state;
		move_up    <= '0';
		move_down  <= '0';
		open_door  <= '0';
		
		case state is
			
			when idle => 
				if pending_req /= "0000" then
					if req_above = '1' then
						next_state <= moving_up;
					elsif req_below = '1' then
						next_state <= moving_down;
					else
					--request is for current_floor
						next_state <= door;
					end if;
				end if;
			
			
			when moving_up =>
				move_up <= '1';
				
				--stop if this floor is requested
				if pending_req(current_floor) = '1' then
					next_state <= door;
				elsif req_above = '0' and req_below = '1' then
					next_state <= moving_down;
				elsif req_above = '0' and req_below = '0' then
					next_state <= idle;
				end if;
				
			when moving_down =>
				move_down <= '1';
				
				--stop if this floor is requested
				if pending_req(current_floor) = '1' then
					next_state <= door;
				elsif req_below = '0' and req_above = '1' then
					next_state <= moving_up;
				elsif req_below = '0' and req_above	= '0' then
					next_state <= idle;
				end if;
				
			
				
			when door =>
				open_door <= '1';
				if door_cnt = DOOR_TIMER then
					if last_dir = up then
						if req_above = '1' then
							next_state <= moving_up;
						elsif req_below = '1' then
							next_state <= moving_down;
						else
							next_state <= idle;
						end if;
					elsif last_dir = down then
						if req_below = '1' then
							next_state <= moving_down;
						elsif req_above = '1' then
							next_state <= moving_up;
						else
							next_state <= idle;
						end if;
					else
						if req_above = '1' then
							next_state <= moving_up;
						elsif req_below = '1' then
							next_state <= moving_down;
						else
							next_state <= idle;
						end if;
					end if;
				end if;
		end case;
	end process;
	

	--Floor movement logic--
	
	process(clk)
	begin
		if rising_edge(clk) then	
			if reset = '1' then
				current_floor <= 0;
			elsif slow_en = '1' then
				case state is
					when moving_up => 
						if current_floor < 3 then
							current_floor <= current_floor + 1;
						else
						
						end if;
					
					when moving_down =>
						if current_floor > 0 then
							current_floor <= current_floor - 1;
						else
						
						end if;
						
					when others =>
						null;
					
				end case;
			end if;
		end if;
	end process;
	
	floor <= std_logic_vector(to_unsigned(current_floor, floor'length));
    
end Behavioral;
