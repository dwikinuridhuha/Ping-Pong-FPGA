library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_driver is
	port (
		clk, reset : in std_logic;
		hsync, vsync : out std_logic;
		video_on, p_tick : out std_logic;
		pixel_x, pixel_y : out std_logic_vector(9 downto 0)
		);
end vga_driver;



architecture behavioral of vga_driver is
-- 640 by 480

--horizontal
constant HDim : integer := 640;
constant HFront : integer := 16;
constant HBack : integer := 48;
constant HRetrace : integer := 96;

--vertical
constant VDim : integer := 480;
constant VFront : integer := 10;
constant VBack : integer := 33;
constant VRetrace : integer := 2;

signal mod2_reg, mod2_next : std_logic;

signal h_count_reg, h_count_next : unsigned (9 downto 0);
signal v_count_reg, v_count_next : unsigned (9 downto 0);

signal v_sync_reg, h_sync_reg : std_logic;
signal v_sync_next, h_sync_next : std_logic;

signal h_end, v_end, pixel_tick : std_logic;

begin
	process (clk,reset)
	begin
		if reset = '1' then
			mod2_reg <= '0';
			v_count_reg <= (others => '0');
			h_count_reg <= (others => '0');
			v_sync_reg <= '0';
			h_sync_reg <= '0';
		elsif (rising_edge(clk)) then 
			mod2_reg <= mod2_next;
			v_count_reg <= v_count_next;
			h_count_reg <= h_count_next;
			v_sync_reg <= v_sync_next;
			h_sync_reg <= h_sync_next;
		end if;
	end process;
	

	--simulating 25 MHz clock 

	mod2_next <= not mod2_reg;
	pixel_tick <= '1' when mod2_reg = '1' else '0';


	-- sum gives 799
	h_end <= '1' when h_count_reg = (HDim + HFront + HBack + HRetrace - 1) else '0';

	v_end <= '1' when v_count_reg = (VDim + VFront + VBack + VRetrace - 1) else '0';

	-- mod 800 horizontal counter


	process (h_count_reg, h_end, pixel_tick)
	begin	
		if pixel_tick = '1' then 
			if h_end = '1' then 
				h_count_next <= (others => '0');
			else 
				h_count_next <= h_count_reg + 1 ;
			end if;
		else
			h_count_next <= h_count_reg;
		end if;
	end process;



	process (v_count_reg, h_end, v_end, pixel_tick)
	begin	
		if pixel_tick = '1' and h_end = '1' then 
			if (v_end = '1') then
				v_count_next <= (others => '0');
			else
				v_count_next <= v_count_reg + 1;
			end if;
		else 
			v_count_next <= v_count_reg;
		end if;
	end process;


	h_sync_next <= '1' when (h_count_reg>=(HDim + HFront)) and (h_count_reg <= (HDim + HFront + HRetrace -1)) else '0';
	v_sync_next <= '1' when (v_count_reg>=(VDim + VFront)) and (v_count_reg <= (VDim + VFront + VRetrace -1)) else '0';

	video_on <= '1' when (h_count_reg < HDim) and (v_count_reg < VDim) else '0';

	hsync <= h_sync_reg;
	vsync <= v_sync_reg;
	pixel_x <= std_logic_vector(h_count_reg);
	pixel_y <= std_logic_vector(v_count_reg);
	p_tick <= pixel_tick;
end behavioral ; -- behavioral












