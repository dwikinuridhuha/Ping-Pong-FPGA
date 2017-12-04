library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity moveable_block is
	generic (
		intial_x_pos : std_logic_vector(9 downto 0) := (others => '0');
		intial_y_pos : std_logic_vector(9 downto 0) := (others => '0');
		width : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		height : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		ball_height : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		ball_width : std_logic_vector(9 downto 0) := (5 => '1',others => '0');
		max_y_position : std_logic_vector(9 downto 0) := (8 => '1', others => '0')
	);
	port (
		clk, reset : in std_logic := '0';
		video_on : in std_logic := '0';
		pixel_x, pixel_y : in std_logic_vector(9 downto 0)  := (others => '0');
		currently_drawing : out std_logic := '0';
		movement_is_activated : in std_logic := '0';
		ball_x_position : in std_logic_vector(9 downto 0);
		ball_y_position : in std_logic_vector(9 downto 0);
		colide_with_ball : out std_logic
	);
end moveable_block;



architecture behavioral of moveable_block is
	signal current_position_x : std_logic_vector(9 downto 0) :=  intial_x_pos;
	signal current_position_y : std_logic_vector(9 downto 0) :=  intial_y_pos;
	signal modulo_counter : std_logic_vector(15 downto 0) := (others => '0');
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
	
	movement : process (clk, reset, modulo_counter)
	begin
	if rising_edge(clk) and to_integer(unsigned( modulo_counter )) = 0 then
		if reset = '1' then
			current_position_x <= intial_x_pos;
			current_position_y <= intial_y_pos;
		elsif movement_is_activated = '1' then
			if to_integer(unsigned( max_y_position )) > to_integer(unsigned( current_position_y )) + to_integer(unsigned( height )) then
				current_position_y <= std_logic_vector(to_unsigned(to_integer(unsigned( current_position_y )) + 1, current_position_y'length));
			else 
			end if;
		else 
			if to_integer(unsigned(current_position_y)) > to_integer(unsigned(intial_y_pos)) then
				current_position_y <= std_logic_vector(to_unsigned(to_integer(unsigned( current_position_y )) - 1, current_position_y'length));
			else
			end if;
		end if;
	end if;
	end process;

	
	
	colision_detector : process (clk, ball_x_position, ball_y_position)
	begin
		if rising_edge(clk) then
			--left upper corner
			if (
			to_integer(unsigned( ball_x_position ))  > to_integer(unsigned( current_position_x ))
			and to_integer(unsigned( ball_x_position )) < to_integer(unsigned( current_position_x )) + to_integer(unsigned( width )) 
			and to_integer(unsigned( ball_y_position )) > to_integer(unsigned( current_position_y ))
			and to_integer(unsigned( ball_y_position )) < to_integer(unsigned( current_position_y )) + to_integer(unsigned( height ))
			)
				or --right upper corner
			(
			to_integer(unsigned( ball_x_position )) + to_integer(unsigned( ball_width )) > to_integer(unsigned( current_position_x ))
			and to_integer(unsigned( ball_x_position )) + to_integer(unsigned( ball_width )) < to_integer(unsigned( current_position_x )) + to_integer(unsigned( width ))
			and to_integer(unsigned( ball_y_position )) > to_integer(unsigned( current_position_y ))
			and to_integer(unsigned( ball_y_position )) < to_integer(unsigned( current_position_y )) + to_integer(unsigned( height ))
			)
				or --
			(
				to_integer(unsigned( ball_x_position ))  > to_integer(unsigned( current_position_x ))
				and to_integer(unsigned( ball_x_position )) < to_integer(unsigned( current_position_x )) + to_integer(unsigned( width )) 
				and to_integer(unsigned( ball_y_position )) + to_integer(unsigned( ball_height )) > to_integer(unsigned( current_position_y ))
				and to_integer(unsigned( ball_y_position )) + to_integer(unsigned( ball_height )) < to_integer(unsigned( current_position_y )) + to_integer(unsigned( height ))
			)
				or
			(
			to_integer(unsigned( ball_x_position ))  > to_integer(unsigned( current_position_x ))
			and to_integer(unsigned( ball_x_position )) < to_integer(unsigned( current_position_x )) + to_integer(unsigned( width )) 
			and to_integer(unsigned( ball_y_position )) > to_integer(unsigned( current_position_y ))
			and to_integer(unsigned( ball_y_position )) < to_integer(unsigned( current_position_y )) + to_integer(unsigned( height ))
			)
			then
				colide_with_ball <= '1';
			else
				colide_with_ball <= '0';
			end if;
		end if;
	end process;
	
	
	
	
end architecture ; -- behavioral