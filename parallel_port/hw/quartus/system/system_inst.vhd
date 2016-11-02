	component system is
		port (
			clk_clk                         : in    std_logic                    := 'X';             -- clk
			parallel_port0_0_export_0_portp : inout std_logic_vector(7 downto 0) := (others => 'X'); -- portp
			parallel_port0_1_export_0_portp : inout std_logic_vector(7 downto 0) := (others => 'X'); -- portp
			reset_reset_n                   : in    std_logic                    := 'X'              -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                         => CONNECTED_TO_clk_clk,                         --                       clk.clk
			parallel_port0_0_export_0_portp => CONNECTED_TO_parallel_port0_0_export_0_portp, -- parallel_port0_0_export_0.portp
			parallel_port0_1_export_0_portp => CONNECTED_TO_parallel_port0_1_export_0_portp, -- parallel_port0_1_export_0.portp
			reset_reset_n                   => CONNECTED_TO_reset_reset_n                    --                     reset.reset_n
		);

