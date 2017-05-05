library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity direct_vga is
	port(
		vga_clock		: in std_logic;
		nios_clock		: in std_logic;
		reset			: in std_logic;
		write_req		: in  std_logic;
		writedata		: in  std_logic_vector(31 downto 0);
		address			: in	std_logic_vector(0 downto 0);
		video_r			: out std_logic_vector(7 downto 0) := "01111111";
		video_g			: out std_logic_vector(7 downto 0) := "01111111";
		video_b			: out std_logic_vector(7 downto 0) := "01111111";
		video_hsync		: out std_logic := '1';
		video_vsync		: out std_logic := '1';
		frame_irq		: out std_logic := '0'
	);
end direct_vga;

architecture behavior of direct_vga is
	
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
	
	signal in_leds : std_logic_vector(31 downto 0) := "10101010101010101010101010101010";
	signal control : std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- 0 - clear frame irq
	
	signal start_frame : std_logic := '0';
	signal reset_frame_irq : std_logic := '0';
	
	TYPE STATE_TYPE IS (s1, s2);
	SIGNAL state   : STATE_TYPE;
	
begin

regs: process(nios_clock,reset,write_req,writedata) is
begin
	if reset = '1' then
		in_leds <= std_logic_vector(to_unsigned(0,32));  
		control <= std_logic_vector(to_unsigned(0,32));
	elsif rising_edge(nios_clock) then
		if write_req = '1' then
			case address is
				when "0" =>
					in_leds <= writedata;
				when "1" =>
					control <= writedata;
			end case;
		end if;
	end if;
end process;

reset_frame_irq <= control(0);

start_frame_process:process(hPos, vPos)
begin
	if((hPos < 400) and (vPos = 0))then
		start_frame <= '1';
	else
		start_frame <= '0';
	end if;
end process;

PROCESS (vga_clock, reset)
   BEGIN
      IF reset = '1' THEN
         state <= s1;
      ELSIF (vga_clock'EVENT AND vga_clock = '1') THEN
         CASE state IS
             WHEN s1=>
               if reset_frame_irq = '1' THEN
                  state <= s2;
               ELSE
                  state <= s1;
               END IF;
            WHEN s2=>
               IF start_frame = '0' THEN
                  state <= s1;
               ELSE
                  state <= s2;
               END IF;
         END CASE;
      END IF;
END PROCESS;

PROCESS (state)
   BEGIN
      CASE state IS
         WHEN s1 =>
            frame_irq <= start_frame;
         WHEN s2 =>
            frame_irq <= '0';
      END CASE;
END PROCESS;

Horizontal_position_counter:process(vga_clock)
begin
	if(vga_clock'event and vga_clock = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(vga_clock, hPos)
begin
	if(vga_clock'event and vga_clock = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(vga_clock, hPos)
begin
	if(vga_clock'event and vga_clock = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			video_hsync <= '1';
		else
			video_hsync <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(vga_clock, vPos)
begin
	if(vga_clock'event and vga_clock = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			video_vsync <= '1';
		else
			video_vsync <= '0';
		end if;
	end if;
end process;


draw:process(vga_clock, hPos, vPos)
begin
	if(vga_clock'event and vga_clock = '1')then
			if(hPos = 0 or hPos = 639 or vPos = 0 or vPos = 479)then
				video_r <= "01111111";
				video_g <= "00000000";
				video_b <= "00000000";
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(31) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 11 and vPos <= 59)) then
				if (in_leds(30) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 11 and vPos <= 59)) then
				if (in_leds(29) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(28) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(27) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(26) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(25) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 11 and vPos <= 59))then
				if (in_leds(24) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
----------------------------------------------
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(23) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 61 and vPos <= 109)) then
				if (in_leds(22) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 61 and vPos <= 109)) then
				if (in_leds(21) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(20) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(19) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(18) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(17) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 61 and vPos <= 109))then
				if (in_leds(16) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
-------------------------------------------------------------------------------
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(15) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 111 and vPos <= 159)) then
				if (in_leds(14) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 111 and vPos <= 159)) then
				if (in_leds(13) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(12) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(11) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(10) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(9) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 111 and vPos <= 159))then
				if (in_leds(8) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
------------------------------------------------------------------------------------
			elsif((hPos >= 11 and hPos <= 59) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(7) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 61 and hPos <= 109) AND (vPos >= 161 and vPos <= 209)) then
				if (in_leds(6) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 111 and hPos <= 159) AND (vPos >= 161 and vPos <= 209)) then
				if (in_leds(5) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 161 and hPos <= 209) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(4) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 211 and hPos <= 259) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(3) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 261 and hPos <= 309) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(2) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 311 and hPos <= 359) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(1) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			elsif ((hPos >= 361 and hPos <= 409) AND (vPos >= 161 and vPos <= 209))then
				if (in_leds(0) = '1') then 
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				else 
					video_r <= "00111111";
					video_g <= "00111111";
					video_b <= "00111111";
				end if;
			else
				video_r <= "00000000";
				video_g <= "00000000";
				video_b <= "00000000";
			end if;
	end if;
end process;


end behavior;
