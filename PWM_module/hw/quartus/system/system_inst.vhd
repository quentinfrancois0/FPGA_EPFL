	component system is
		port (
			clk_clk           : in  std_logic := 'X'; -- clk
			reset_reset_n     : in  std_logic := 'X'; -- reset_n
			pwm_export_export : out std_logic         -- export
		);
	end component system;

	u0 : component system
		port map (
			clk_clk           => CONNECTED_TO_clk_clk,           --        clk.clk
			reset_reset_n     => CONNECTED_TO_reset_reset_n,     --      reset.reset_n
			pwm_export_export => CONNECTED_TO_pwm_export_export  -- pwm_export.export
		);

