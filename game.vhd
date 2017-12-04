library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity game is
	port (
		clk, reset : in std_logic := '0';
		hsync, vsync : out std_logic := '0';
		vga_r : out std_logic_vector(3 downto 0) := (others => '0');
		vga_g : out std_logic_vector(3 downto 0) := (others => '0');
		vga_b : out std_logic_vector(3 downto 0) := (others => '0');
		bt : in std_logic_vector(3 downto 0) := (others => '0')
		);
end game;



architecture behavioral of game is

signal video_on : std_logic := '0';
signal p_tick : std_logic := '0';
signal pixel_x : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y : std_logic_vector(9 downto 0) := (others => '0');


signal paddle_one_is_drawing : std_logic := '0';
signal ball_is_drawing : std_logic := '0';
signal paddle_two_is_drawing : std_logic := '0';
signal left_wall_is_drawing : std_logic := '0';
signal right_wall_is_drawing : std_logic := '0';
signal top_wall_is_drawing : std_logic := '0';
signal bottom_wall_is_drawing : std_logic := '0';

signal paddle_one_is_colliding : std_logic := '0';
signal paddle_two_is_colliding : std_logic := '0';
signal left_wall_is_colliding : std_logic := '0';
signal right_wall_is_colliding : std_logic := '0';
signal top_wall_is_colliding : std_logic := '0';
signal bottom_wall_is_colliding : std_logic := '0';

signal left_player_points : integer := 0;
signal right_player_points : integer := 0;
signal left_player_scored : std_logic := '0';
signal right_player_scored : std_logic := '0';

signal reset_game : std_logic := '0';

signal x_position_of_ball : std_logic_vector(9 downto 0);
signal y_position_of_ball : std_logic_vector(9 downto 0);
signal first_paddle_is_moving : std_logic := '0';
signal second_paddle_is_moving : std_logic := '0';


signal x_ball_multiplier : std_logic := '0';
signal y_ball_multiplier : std_logic := '0';

	--vga driver
	component vga_driver is
	port (
		clk, reset : in std_logic;
		hsync, vsync : out std_logic;
		video_on, p_tick : out std_logic;
		pixel_x, pixel_y : out std_logic_vector(9 downto 0)
		);
	end component;

	--paddle
	component moveable_block is
	generic (
		intial_x_pos : std_logic_vector(9 downto 0);
		intial_y_pos : std_logic_vector(9 downto 0);
		width : std_logic_vector(9 downto 0);
		height : std_logic_vector(9 downto 0);
		ball_height : std_logic_vector(9 downto 0);
		ball_width : std_logic_vector(9 downto 0)
	);
	port (
		clk, reset : in std_logic := '0';
		video_on : in std_logic := '0';
		pixel_x, pixel_y : in std_logic_vector(9 downto 0);
		currently_drawing : out std_logic;
		movement_is_activated : in std_logic;
		ball_x_position : in std_logic_vector(9 downto 0);
		ball_y_position : in std_logic_vector(9 downto 0);
		colide_with_ball : out std_logic
	);
	end component;
	
	
	component ball is
	generic (
		intial_x_pos : std_logic_vector(9 downto 0);
		intial_y_pos : std_logic_vector(9 downto 0);
		width : std_logic_vector(9 downto 0);
		height : std_logic_vector(9 downto 0);
		vertical_movement_factor : std_logic_vector(9 downto 0);
		horizontal_movement_factor : std_logic_vector(9 downto 0)
	);
	port (
		clk, reset : in std_logic := '0';
		video_on : in std_logic := '0';
		pixel_x, pixel_y : in std_logic_vector(9 downto 0);
		currently_drawing : out std_logic := '0';
		x_multiplier : in std_logic := '0';
		y_multiplier : in std_logic := '0';
		
		x_current_position : out std_logic_vector(9 downto 0);
		y_current_position : out std_logic_vector(9 downto 0)

		);
	end component;
	
	
	
	
begin
	
	vga_driver_unit : entity work.vga_driver
		port map (
				clk => clk, 
				reset=>reset, 
				hsync=>hsync,
				vsync=>vsync, 
				video_on => video_on,
				p_tick => p_tick, 
				pixel_x=>pixel_x,
				pixel_y=>pixel_y
		);
		pad1 : entity work.moveable_block
		generic map (
			intial_x_pos => "1000110011",
			intial_y_pos => "0000001111",
			height => "0001100000",
			ball_height => "0000001111",
			ball_width => "0000001111",
			max_y_position => "0110010000"
		)
		port map (
				clk => p_tick, 
				reset=>reset_game, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing => paddle_one_is_drawing,
				movement_is_activated => first_paddle_is_moving,
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => paddle_one_is_colliding
		);
		pad2 : entity work.moveable_block
		generic map (
			intial_x_pos => "0000101101",
			intial_y_pos => "0000001111",
			height => "0001100000",
			ball_height => "0000001111",
			ball_width => "0000001111",
			max_y_position => "0110010000"
		)
		port map (
				clk => p_tick, 
				reset=>reset_game, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>paddle_two_is_drawing,
				movement_is_activated => second_paddle_is_moving,
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => paddle_two_is_colliding
		);
			
		pongball : entity work.ball
		generic map (
			intial_x_pos => "0100101100",
			intial_y_pos => "0011111010",
			width => "0000001111",
			height => "0000001111",
			vertical_movement_factor => "0000000001",
			horizontal_movement_factor => "0000000001"
		)
		port map (
				clk => p_tick, 
				reset=>reset_game, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>ball_is_drawing,
				x_multiplier => x_ball_multiplier,
				y_multiplier => y_ball_multiplier,
				x_current_position => x_position_of_ball,
				y_current_position => y_position_of_ball
		);
		
		leftWall : entity work.moveable_block
		generic map (
			intial_x_pos => "0000000000",
			intial_y_pos => "0000000000",
			width  => "0000001111",
			height => "0110010000",
			ball_height => "0000001111",
			ball_width => "0000001111"
		)
		port map (
				clk => clk, 
				reset=>reset, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>left_wall_is_drawing,
				movement_is_activated => '0',
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => left_wall_is_colliding
		);
		topWall : entity work.moveable_block
		generic map (
			intial_x_pos => "0000001111",
			intial_y_pos => "0000000000",
			width  => "1001110001",
			height => "0000001111",
			ball_height => "0000001111",
			ball_width => "0000001111"
		)
		port map (
				clk => p_tick, 
				reset=>reset, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>top_wall_is_drawing,
				movement_is_activated => '0',
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => top_wall_is_colliding
		);	
		rightWall : entity work.moveable_block
		generic map (
			intial_x_pos => "1001110001",
			--intial_x_pos => "1000000001",

			intial_y_pos => "0000001111",
			width  => "0000001111",
			--width  => "0000000011",

			height => "0110010000",
			ball_height => "0000001111",
			ball_width => "0000001111"
		)
		port map (
				clk => clk, 
				reset=>reset, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>right_wall_is_drawing,
				movement_is_activated => '0',
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => right_wall_is_colliding
		);			
		bottomWall : entity work.moveable_block
		generic map (
			intial_x_pos => "0000000000",
			intial_y_pos => "0110010000",
			width  => "1001110001",
			height => "0000001111",
			ball_height => "0000001111",
			ball_width => "0000001111"
		)
		port map (
				clk => p_tick, 
				reset=>reset, 
				video_on => video_on,
				pixel_x=>pixel_x,
				pixel_y=>pixel_y,
				currently_drawing=>bottom_wall_is_drawing,
				movement_is_activated => '0',
				ball_x_position => x_position_of_ball,
				ball_y_position => y_position_of_ball,
				colide_with_ball => bottom_wall_is_colliding
		);		
	background_color : process (video_on, paddle_one_is_drawing, paddle_two_is_drawing, left_wall_is_drawing,
										top_wall_is_drawing, right_wall_is_drawing, bottom_wall_is_drawing, ball_is_drawing,
										right_player_points, left_player_points)
	begin
	if video_on = '1' then
		if paddle_one_is_drawing = '1' then
			vga_r <= "1001";
			vga_g <= "1001";
			vga_b <= "1111";
		elsif paddle_two_is_drawing = '1' then
			vga_r <= "1111";
			vga_g <= "1111";
			vga_b <= "1111";
		elsif top_wall_is_drawing = '1' or bottom_wall_is_drawing = '1' then 
			vga_r <= "0110";
			vga_g <= "1111";
			vga_b <= "0000";
		elsif ball_is_drawing = '1' then
			vga_r <= "0000";
			vga_g <= "0000";
			vga_b <= "1111";
		elsif right_wall_is_drawing = '1' then 
			if right_player_points = 0 then
				vga_r <= "0001";
				vga_g <= "0001";
				vga_b <= "0001";
			elsif right_player_points = 1 then
				vga_r <= "0011";
				vga_g <= "0011";
				vga_b <= "0011";
			elsif right_player_points = 2 then
				vga_r <= "0111";
				vga_g <= "0111";
				vga_b <= "0111";
			else
				vga_r <= "1111";
				vga_g <= "1111";
				vga_b <= "1111";
			end if;
		elsif left_wall_is_drawing = '1' then 
			if left_player_points = 0 then
				vga_r <= "0001";
				vga_g <= "0001";
				vga_b <= "0001";
			elsif left_player_points = 1 then
				vga_r <= "0011";
				vga_g <= "0011";
				vga_b <= "0011";
			elsif left_player_points = 2 then
				vga_r <= "0111";
				vga_g <= "0111";
				vga_b <= "0111";
			else
				vga_r <= "1111";
				vga_g <= "1111";
				vga_b <= "1111";
			end if;
		else
			vga_r <= "0110";
			vga_g <= "0000";
			vga_b <= "0000";
		end if;
	else
			vga_r <= "0000";
			vga_g <= "0000";
			vga_b <= "0000";
	end if;
	end process;

	user_interaction : process (bt,clk)
	begin
	if rising_edge(clk) then
		if (bt(0) = '1' or bt(1) = '1') then 
			first_paddle_is_moving <= '1';
		elsif (bt(2) = '1' or bt(3) = '1') then
			second_paddle_is_moving <= '1';
		else 
			second_paddle_is_moving <= '0';
			first_paddle_is_moving <= '0';
		end if;
	end if;
	end process;
	
	
	collision_resolver : process (p_tick, left_wall_is_colliding, right_wall_is_colliding, paddle_one_is_colliding,
											paddle_two_is_colliding, top_wall_is_colliding, bottom_wall_is_colliding)
	begin
			if left_wall_is_colliding = '1' then 
				x_ball_multiplier <= '1';
				right_player_scored <= '1';
				left_player_scored <= '0';
			elsif right_wall_is_colliding = '1' then 
				x_ball_multiplier <= '1';
				left_player_scored <= '1';
				right_player_scored <= '0';
			elsif paddle_two_is_colliding = '1' or
				paddle_one_is_colliding = '1' then
				x_ball_multiplier <= '1';
				left_player_scored <= '0';
				right_player_scored <= '0';
			else
				x_ball_multiplier <= '0';
				left_player_scored <= '0';
				right_player_scored <= '0';
			end if;	
			if top_wall_is_colliding = '1' or
			bottom_wall_is_colliding = '1' then
				y_ball_multiplier <= '1';
			else
				y_ball_multiplier <= '0';
			end if;
	end process;

	someone_scored : process (left_player_scored, right_player_scored, clk)
	begin
	if rising_edge(clk) then
		if left_player_scored = '1' then 
			left_player_points <= left_player_points + 1;
			if left_player_points = 4 then
				left_player_points <= 0;
			else
			end if;
			reset_game <= '1';
		elsif right_player_scored = '1' then
			right_player_points <= right_player_points + 1;
			if right_player_points = 4 then
				right_player_points <= 0;
			else
			end if;
			reset_game <= '1';
		else
			reset_game <= '0';
		end if;
		
	else
	end if;
	end process;
end architecture ; -- arch
