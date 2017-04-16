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
		VIDEO_VSYNC		: out std_logic := '1';
		pMemClk     : out std_logic;                        -- SD-RAM Clock
		pMemCke     : out std_logic;                        -- SD-RAM Clock enable
		pMemCs_n    : out std_logic;                        -- SD-RAM Chip select
		pMemRas_n   : out std_logic;                        -- SD-RAM Row/RAS
		pMemCas_n   : out std_logic;                        -- SD-RAM /CAS
		pMemWe_n    : out std_logic;                        -- SD-RAM /WE
		pMemUdq     : out std_logic;                        -- SD-RAM UDQM
		pMemLdq     : out std_logic;                        -- SD-RAM LDQM
		pMemBa1     : out std_logic;                        -- SD-RAM Bank select address 1
		pMemBa0     : out std_logic;                        -- SD-RAM Bank select address 0
		pMemAdr     : out std_logic_vector(11 downto 0);    -- SD-RAM Address
		pMemDat     : inout std_logic_vector(15 downto 0)   -- SD-RAM Data

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
	
	signal vga_clk : std_logic := '0';
	signal OUT_LED : std_logic_vector(7 downto 0) := "10011111";	
	
	
	component embcpumem is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X';  -- reset_n
				pio_0_external_connection_export : out std_logic_vector(7 downto 0);         -- export
            new_sdram_controller_0_wire_addr  : out   std_logic_vector(11 downto 0);                    -- addr
            new_sdram_controller_0_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
            new_sdram_controller_0_wire_cas_n : out   std_logic;                                        -- cas_n
            new_sdram_controller_0_wire_cke   : out   std_logic;                                        -- cke
            new_sdram_controller_0_wire_cs_n  : out   std_logic;                                        -- cs_n
            new_sdram_controller_0_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            new_sdram_controller_0_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
            new_sdram_controller_0_wire_ras_n : out   std_logic;                                        -- ras_n
            new_sdram_controller_0_wire_we_n  : out   std_logic                                         -- we_n
			);
    end component embcpumem;

	component vgaClock is
        port (
            inclk0       : in std_logic := '0'; -- clk
            c0 : out std_logic
			);
    end component vgaClock;

begin
    niosinst : component embcpumem
        port map (
            clk_clk       => CLK_20,       --   clk.clk
            reset_reset_n => RST,  -- reset.reset_n
				pio_0_external_connection_export => OUT_LED,  -- pio_0_external_connection.export
            new_sdram_controller_0_wire_addr  => pMemAdr,  -- new_sdram_controller_0_wire.addr
            new_sdram_controller_0_wire_ba(0)    => pMemBa0,    --                            .ba
            new_sdram_controller_0_wire_ba(1)    => pMemBa1,    --                            .ba
            new_sdram_controller_0_wire_cas_n    => pMemCas_n, --                            .cas_n
            new_sdram_controller_0_wire_cke      => pMemCke,   --                            .cke
            new_sdram_controller_0_wire_cs_n     => pMemCs_n,  --                            .cs_n
            new_sdram_controller_0_wire_dq       => pMemDat,    --                            .dq
            new_sdram_controller_0_wire_dqm(0)   => pMemUdq,   --                            .dqm
            new_sdram_controller_0_wire_dqm(1)   => pMemLdq,   --                            .dqm
            new_sdram_controller_0_wire_ras_n    => pMemRas_n, --                            .ras_n
            new_sdram_controller_0_wire_we_n     => pMemWe_n   --                            .we_n
        );
		  
	vgaClockInst : component vgaClock
		port map (
			inclk0 => CLK_20,
			c0 => vga_clk
		);

pMemClk   <= CLK_20;

Horizontal_position_counter:process(vga_clk)
begin
	if(vga_clk'event and vga_clk = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(vga_clk, hPos)
begin
	if(vga_clk'event and vga_clk = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(vga_clk, hPos)
begin
	if(vga_clk'event and vga_clk = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			VIDEO_HSYNC <= '1';
		else
			VIDEO_HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(vga_clk, vPos)
begin
	if(vga_clk'event and vga_clk = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VIDEO_VSYNC <= '1';
		else
			VIDEO_VSYNC <= '0';
		end if;
	end if;
end process;


draw:process(vga_clk, hPos, vPos)
begin
	if(vga_clk'event and vga_clk = '1')then
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
