LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity testbench is
   -- Nothing as input/output
end testbench;

ARCHITECTURE bhv OF testbench IS
-- The system to test under simulation
component PWM is
   PORT(
    nReset	: IN std_logic;
		Clk		: IN std_logic;
		Addr	: IN std_logic_vector (2 DOWNTO 0);
		R		: IN std_logic;
		W		: IN std_logic;
		RData	: OUT std_logic_vector (7 DOWNTO 0);
		WData	: IN std_logic_vector (7 DOWNTO 0);
		PWMOut	: OUT std_logic
);
	end component;

-- The interconnection signals:
	signal nReset	: std_logic := '1';
	signal Clk      : std_logic := '0';
	signal Addr     : std_logic_vector (2 DOWNTO 0) := "000";
	signal R		: std_logic := '0'; --Read pin
	signal W		: std_logic := '0'; --Write pin
	signal RData   : std_logic_vector (7 DOWNTO 0) := "00000000"; 
	signal WData   : std_logic_vector (7 DOWNTO 0) := "00000000";
	signal PWMOut    : std_logic := '0';
	signal end_sim  : boolean := false;
   	constant HalfPeriod  : TIME := 10 ns;  -- 50 MHz -> 20ns/2 -> 10 ns
	
BEGIN 
DUT : PWM               -- Component to Test as Device Under Test       
     Port MAP( 
	Clk => Clk,  		 -- from component => signals in the architecture 
	nReset => nReset,
	Addr => Addr,
	R => R,
	W => W,
	RData => RData,
	WData => WData,
	PWMOut => PWMOut
    ); 
	
-- Clock generation for all simulation time 
clk_process : 
process
   begin
	if not end_sim then
		Clk <= '0'; 
		wait for HalfPeriod; 
		Clk <= '1'; 
		wait for HalfPeriod;
	else 
		wait;
	end if;
end process;


test :
process

	procedure toggle_reset is
	begin
		nReset <= '0';
		wait until falling_edge(clk);
		
		nReset <= '1';
		wait until falling_edge(clk);
	end procedure;

	procedure write_register(addr_write: std_logic_vector; data: std_logic_vector) is
	begin
		W <= '1';
		R <= '0';
		Addr <= addr_write;
		WData <= data;
		wait until falling_edge(clk);
		
		W <= '0';
		Addr <= "000";
		WData <= "00000000";
		wait until falling_edge(clk);
	end procedure;
	
	procedure read_register(addr_read: std_logic_vector) is
	begin
		W <= '0';
		R <= '1';
		Addr <= addr_read;
		wait until falling_edge(clk);
		
		R <= '0';
		Addr <= "000";
		wait until falling_edge(clk);
	end procedure;

begin
	toggle_reset;
	
	-- Writing clock_divider = 0, period = 256 * (2*HalfPeriod) = 5,12 us
	write_register("000", X"01");
	write_register("001", X"00");
	wait for 4 * HalfPeriod; -- ligne qui empêche d'écrire le registre duty cycle
	
	-- Writing duty cycle = 50%
	write_register("010", X"80");
	
	-- Writing polarity = 1
	write_register("011", X"01");
	
	-- Writing control = 1
	write_register("101", X"01");
	
	-- Wait for 1 period of the PWM
	wait for 1024 * 2 * HalfPeriod;
	
	end_sim <= true;
	wait;
	
end process;

END bhv;