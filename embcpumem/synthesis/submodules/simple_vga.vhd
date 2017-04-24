library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simple_vga is
	port(
		clock				: in std_logic;
		reset				: in std_logic;
		in_leds			: in std_logic_vector(7 downto 0);
		video_r			: out std_logic_vector(7 downto 0) := "01111111";
		video_g			: out std_logic_vector(7 downto 0) := "01111111";
		video_b			: out std_logic_vector(7 downto 0) := "01111111";
		video_hsync		: out std_logic := '1';
		video_vsync		: out std_logic := '1'
	);
end simple_vga;

architecture behaivor of simple_vga is
	
	constant HD : integer := 639;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant HSP : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
begin

Horizontal_position_counter:process(clock)
begin
	if(clock'event and clock = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(clock, hPos)
begin
	if(clock'event and clock = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(clock, hPos)
begin
	if(clock'event and clock = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			video_hsync <= '1';
		else
			video_hsync <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(clock, vPos)
begin
	if(clock'event and clock = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			video_vsync <= '1';
		else
			video_vsync <= '0';
		end if;
	end if;
end process;


draw:process(clock, hPos, vPos)
begin
	if(clock'event and clock = '1')then
			if(hPos = 0 or hPos = 639 or vPos = 0 or vPos = 479)then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "01111111";
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 10 and vPos <= 60) AND (in_leds(7) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 10 and vPos <= 60) AND (in_leds(6) = '1')) then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 10 and vPos <= 60) AND (in_leds(5) = '1')) then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 10 and vPos <= 60) AND (in_leds(4) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 10 and vPos <= 60) AND (in_leds(3) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 10 and vPos <= 60) AND (in_leds(2) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 10 and vPos <= 60) AND (in_leds(1) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 10 and vPos <= 60) AND (in_leds(0) = '1'))then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			else
				video_r <= "00000000";
				video_g <= "00000000";
				video_b <= "00000000";
			end if;
	end if;
end process;


end behaivor;
