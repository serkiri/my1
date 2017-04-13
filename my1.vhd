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
	signal RST : std_logic := '1';
	
	signal counter : integer range 0 to 20000000 := 0;
	signal OUT_LED : std_logic_vector(7 downto 0) := "10011111";
	
	
	component embcpu is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X';  -- reset_n
				pio_0_external_connection_export : out std_logic_vector(7 downto 0)         -- export
        );
    end component embcpu;


begin
    niosinst : component embcpu
        port map (
            clk_clk       => CLK_20,       --   clk.clk
            reset_reset_n => RST,  -- reset.reset_n
				pio_0_external_connection_export => OUT_LED  -- pio_0_external_connection.export
        );  

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


draw:process(CLK_20, hPos, vPos)
begin
	if(CLK_20'event and CLK_20 = '1')then
			if(hPos = 0 or hPos = 639 or vPos = 0 or vPos = 479)then
				VIDEO_R <= "01111111";
				VIDEO_G <= "01111111";
				VIDEO_B <= "01111111";
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(7) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(6) = '1')) then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(5) = '1')) then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(4) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(3) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(2) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(1) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 10 and vPos <= 60) AND (OUT_LED(0) = '1'))then
				VIDEO_R <= "01111111";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			else
				VIDEO_R <= "00000000";
				VIDEO_G <= "00000000";
				VIDEO_B <= "00000000";
			end if;
	end if;
end process;


end rtl;
