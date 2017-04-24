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
	signal vga_clk : std_logic := '0';
	signal nios_clk : std_logic := '0';
	signal mem_clk : std_logic := '0';
	
	signal RST : std_logic := '1';	
	
	component embcpumem is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X';  -- reset_n
            new_sdram_controller_0_wire_addr  : out   std_logic_vector(11 downto 0);                    -- addr
            new_sdram_controller_0_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
            new_sdram_controller_0_wire_cas_n : out   std_logic;                                        -- cas_n
            new_sdram_controller_0_wire_cke   : out   std_logic;                                        -- cke
            new_sdram_controller_0_wire_cs_n  : out   std_logic;                                        -- cs_n
            new_sdram_controller_0_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            new_sdram_controller_0_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
            new_sdram_controller_0_wire_ras_n : out   std_logic;                                        -- ras_n
            new_sdram_controller_0_wire_we_n  : out   std_logic;                                         -- we_n
				simple_vga_r                      : out   std_logic_vector(7 downto 0);                     -- r
            simple_vga_g                      : out   std_logic_vector(7 downto 0);                     -- g
            simple_vga_b                      : out   std_logic_vector(7 downto 0);                     -- b
            simple_vga_hsync                  : out   std_logic;                                        -- hsync
            simple_vga_vsync                  : out   std_logic;                                        -- vsync
            vga_clock_clk                     : in    std_logic                     := 'X'              -- clk
			);
    end component embcpumem;

	component vgaClock is
        port (
            inclk0       : in std_logic := '0'; -- clk
            c0 : out std_logic;
				c1 : out std_logic;
				c2 : out std_logic
			);
    end component vgaClock;

begin
    niosinst : component embcpumem
        port map (
            clk_clk       => nios_clk,       --   clk.clk
            reset_reset_n => RST,  -- reset.reset_n
            new_sdram_controller_0_wire_addr  => pMemAdr,  -- new_sdram_controller_0_wire.addr
            new_sdram_controller_0_wire_ba(0)    => pMemBa0,    --                            .ba
            new_sdram_controller_0_wire_ba(1)    => pMemBa1,    --                            .ba
            new_sdram_controller_0_wire_cas_n    => pMemCas_n, --                            .cas_n
            new_sdram_controller_0_wire_cke      => pMemCke,   --                            .cke
            new_sdram_controller_0_wire_cs_n     => pMemCs_n,  --                            .cs_n
            new_sdram_controller_0_wire_dq       => pMemDat,    --                            .dq
            new_sdram_controller_0_wire_dqm(0)   => pMemLdq,   --                            .dqm
            new_sdram_controller_0_wire_dqm(1)   => pMemUdq,   --                            .dqm
            new_sdram_controller_0_wire_ras_n    => pMemRas_n, --                            .ras_n
            new_sdram_controller_0_wire_we_n     => pMemWe_n,   --                            .we_n
				simple_vga_r                      => VIDEO_R,                      --                  simple_vga.r
            simple_vga_g                      => VIDEO_G,                      --                            .g
            simple_vga_b                      => VIDEO_B,                      --                            .b
            simple_vga_hsync                  => VIDEO_HSYNC,                  --                            .hsync
            simple_vga_vsync                  => VIDEO_VSYNC,                  --                            .vsync
            vga_clock_clk                     => vga_clk                      --                   vga_clock.clk
        );
		  
	vgaClockInst : component vgaClock
		port map (
			inclk0 => CLK_20,
			c0 => vga_clk,
			c1 => nios_clk,
			c2 => mem_clk
		);

pMemClk	<= mem_clk;

end rtl;
