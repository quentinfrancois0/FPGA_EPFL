LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity testbench is
   -- Nothing as input/output
end testbench;

ARCHITECTURE bhv OF testbench IS
-- The system to test under simulation
component Parallel_port is
   PORT(
    nReset	: IN std_logic;
	Clk		: IN std_logic;
	Addr	: IN std_logic_vector (2 DOWNTO 0);
	R		: IN std_logic; --Read pin
	W		: IN std_logic; --Write pin
	RDData	: OUT std_logic_vector (7 DOWNTO 0); 
	WRData	: IN std_logic_vector (7 DOWNTO 0);
	PortP	: INOUT std_logic_vector (7 DOWNTO 0)
);
	end component;

-- The interconnection signals:
	signal nReset	: std_logic := '1';
	signal Clk      : std_logic := '0';
	signal Addr     : std_logic_vector (2 DOWNTO 0) := "000";
	signal R		: std_logic := '0'; --Read pin
	signal W		: std_logic := '0'; --Write pin
	signal RDData   : std_logic_vector (7 DOWNTO 0) := "00000000"; 
	signal WRData   : std_logic_vector (7 DOWNTO 0) := "00000000";
	signal PortP    : std_logic_vector (7 DOWNTO 0) := "00000000";
	signal end_sim  : boolean := false;
   	constant HalfPeriod  : TIME := 10 ns;  -- 50 MHz -> 20ns/2 -> 10 ns
	
BEGIN 
DUT : Parallel_port               -- Component to Test as Device Under Test       
     Port MAP( 
	Clk => Clk,  		 -- from component => signals in the architecture 
	nReset => nReset,
	Addr => Addr,
	R => R,
	W => W,
	RDData => RDData,
	WRData => WRData,
	PortP => PortP
    ); 
	
-- Clock generation for all simulation time 
clk_process : 
process
   begin
	if not end_sim then
		clk <= '0'; 
		wait for HalfPeriod; 
		clk <= '1'; 
		wait for HalfPeriod;
	else 
		wait;
	end if;
end process;

direction_process :
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
		WRData <= data;
		wait until falling_edge(clk);
		
		W <= '0';
		Addr <= "000";
		WRData <= "00000000";
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

	wait until falling_edge(clk);
	
	toggle_reset;
	
	-- Writing dir and port registers
	-- write_register("000", X"f0");
	-- write_register("010", X"ff");
	-- wait for 4 * HalfPeriod;
	
	-- Testing set function
	-- write_register("000", X"f0");
	-- PortP <= "X73";
	-- write_register("011", X"ff");
	-- wait for 4 * HalfPeriod;
	
	-- Testing clear function
	write_register("000", X"ff");
	PortP <= X"73";
	write_register("100", X"ff");
	read_register("001");
	wait for 4 * HalfPeriod;
	
	-- Reading the pin register
	-- write_register("000", X"00");
	-- PortP <= "10101010";
	-- read_register("001");
	-- wait for 4 * HalfPeriod;
	
	end_sim <= true;
	wait;
	
end process;

END bhv;