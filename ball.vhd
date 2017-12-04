library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ball is
	generic (
		intial_x_pos : std_logic_vector(9 downto 0) := (others => '0');
		intial_y_pos : std_logic_vector(9 downto 0) := (others => '0');
		width : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		height : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		vertical_movement_factor : std_logic_vector(9 downto 0) := (others => '0');
		horizontal_movement_factor : std_logic_vector(9 downto 0) := (1 => '1',others => '0')
	);
	port (
		clk, reset : in std_logic := '0';
		video_on : in std_logic := '0';
		pixel_x, pixel_y : in std_logic_vector(9 downto 0)  := (others => '0');
		currently_drawing : out std_logic := '0';
		x_multiplier : in std_logic := '0';
		y_multiplier : in std_logic := '0';
		
		x_current_position : out std_logic_vector(9 downto 0)  := (others => '0');
		y_current_position : out std_logic_vector(9 downto 0)  := (others => '0')

		);
end ball;



architecture behavioral of ball is

	signal current_position_x : std_logic_vector(9 downto 0) :=  intial_x_pos;
	signal current_position_y : std_logic_vector(9 downto 0) :=  intial_y_pos;
	signal modulo_counter : std_logic_vector(15 downto 0) := (others => '0');
	signal ball_movement_modulo_counter : std_logic_vector(18 downto 0) := (others => '0');
	-- x collision
	signal direction_x : integer := 1;
	signal ignore_changes_x : std_logic := '0';
	signal ignore_counter_x : std_logic_vector(5 downto 0) := (others => '0');
	-- y collision
	signal direction_y : integer := 1;
	signal ignore_changes_y : std_logic := '0';
	signal ignore_counter_y : std_logic_vector(3 downto 0) := (others => '0');
begin
	should_draw : process (video_on, clk)
	begin
	if rising_edge(clk) and video_on = '1' then
		if (to_integer(unsigned(pixel_x)) >= to_integer(unsigned(current_position_x))) and (to_integer(unsigned(pixel_x)) <= to_integer(unsigned(current_position_x)) + to_integer(unsigned(width))) then 
			if (to_integer(unsigned(pixel_y)) >= to_integer(unsigned(current_position_y))) and (to_integer(unsigned(pixel_y)) <= to_integer(unsigned(current_position_y)) + to_integer(unsigned(height))) then 
				currently_drawing <= '1';
			else 
				currently_drawing <= '0';
			end if;
		else 
			currently_drawing <= '0';
		end if;
	end if;
	end process;
	
	
	modctr : process (clk)
	begin 
		if rising_edge(clk) then
		modulo_counter <= std_logic_vector(to_unsigned(to_integer(unsigned( modulo_counter )) + 1, modulo_counter'length));
		else
	end if;
	end process;
	
	modctrball : process (clk)
	begin 
		if rising_edge(clk) then
		ball_movement_modulo_counter <= std_logic_vector(to_unsigned(to_integer(unsigned( ball_movement_modulo_counter )) + 1, ball_movement_modulo_counter'length));
		else
	end if;
	end process;
	
	
	
	
	movement : process (clk, reset, modulo_counter,x_multiplier,y_multiplier,current_position_x,current_position_y)
	begin
	if rising_edge(clk) and to_integer(unsigned( modulo_counter )) = 0 then
		if reset = '1' then
			current_position_x <= intial_x_pos;
			current_position_y <= intial_y_pos;
		else
			if x_multiplier = '1' and ignore_changes_x = '0' then 
				if direction_x = 1 then
					direction_x <= 2;
					current_position_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_x)) - 
							5
							, current_position_x'length));
				else 
					direction_x <= 1;
					current_position_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_x)) + 
							5
							, current_position_x'length));
				end if;
				ignore_changes_x <= '1';
				ignore_counter_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(ignore_counter_x)) + 1
							, ignore_counter_x'length));
			else
				if direction_x = 2  then 
				current_position_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_x)) - 
							to_integer(unsigned(horizontal_movement_factor))
							, current_position_x'length));
				else
				current_position_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_x)) + 
							to_integer(unsigned(horizontal_movement_factor))
							, current_position_x'length));
				end if;
				if ignore_changes_x = '1' then
					if to_integer(unsigned(ignore_counter_x)) = 0 then
						ignore_changes_x <= '0';
					else
						ignore_counter_x <= std_logic_vector(to_unsigned(
							to_integer(unsigned(ignore_counter_x)) + 1
							, ignore_counter_x'length));
					end if;
				else
				end if;
			end if;
				
			
			-- y position
			
			
			
			if y_multiplier = '1' and ignore_changes_y = '0' then 
				if direction_y = 1 then
					direction_y <= 2;
					current_position_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_y)) - 
							5
							, current_position_y'length));
				else 
					direction_y <= 1;
					current_position_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_y)) + 
							5
							, current_position_y'length));
				end if;
				ignore_changes_y <= '1';
				ignore_counter_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(ignore_counter_y)) + 1
							, ignore_counter_y'length));
			else
				if direction_y = 2  then 
				current_position_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_y)) - 
							to_integer(unsigned(vertical_movement_factor))
							, current_position_y'length));
				else
				current_position_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(current_position_y)) + 
							to_integer(unsigned(vertical_movement_factor))
							, current_position_y'length));
				end if;
				if ignore_changes_y = '1' then
					if to_integer(unsigned(ignore_counter_y)) = 0 then
						ignore_changes_y <= '0';
					else
						ignore_counter_y <= std_logic_vector(to_unsigned(
							to_integer(unsigned(ignore_counter_y)) + 1
							, ignore_counter_y'length));
					end if;
				else
				end if;
			end if;
			
			
			
			
			
			
			-- y position
			
			
			
		end if;
		x_current_position <= current_position_x;
		y_current_position <= current_position_y;
	end if;
	
	end process;
	
	
	
end architecture ; -- behavioral