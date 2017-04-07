library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity my1_top is
	port(
		CLK_20			: in std_logic;
		VIDEO_R			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_G			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_B			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_HSYNC		: out std_logic := '1';
		VIDEO_VSYNC		: out std_logic := '1'

	);
  
end my1_top;

architecture rtl of my1_top is
	
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
	
	signal videoOn : std_logic := '0';
begin

Horizontal_position_counter:process(CLK_20)
begin
	if(CLK_20'event and CLK_20 = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(CLK_20, hPos)
begin
	if(CLK_20'event and CLK_20 = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(CLK_20, hPos)
begin
	if(CLK_20'event and CLK_20 = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			VIDEO_HSYNC <= '1';
		else
			VIDEO_HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(CLK_20, vPos)
begin
	if(CLK_20'event and CLK_20 = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VIDEO_VSYNC <= '1';
		else
			VIDEO_VSYNC <= '0';
		end if;
	end if;
end process;

video_on:process( hPos, vPos)
begin

		if(hPos <= HD and vPos <= VD)then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;

end process;


draw:process(CLK_20, hPos, vPos, videoOn)
begin
	if(CLK_20'event and CLK_20 = '1')then
		if(videoOn = '1')then
			if(hPos = 0 or hPos = 639 or vPos = 0 or vPos = 479)then
				VIDEO_R <= "11111111";
				VIDEO_G <= "11111111";
				VIDEO_B <= "11111111";
			elsif((hPos >= 10 and hPos <= 60) AND (vPos >= 10 and vPos <= 60))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 61 and hPos <= 120) AND (vPos >= 10 and vPos <= 60)) then
				VIDEO_R <= "00111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 121 and hPos <= 180) AND (vPos >= 10 and vPos <= 60)) then
				VIDEO_R <= "00011111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			else
				VIDEO_R <= "00000000";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			end if;
		else
			VIDEO_R <= "00000000";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		end if;
	end if;
end process;

end rtl;
