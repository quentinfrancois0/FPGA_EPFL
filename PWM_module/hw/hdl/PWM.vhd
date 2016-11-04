-- Design of a PWM module
-- Avalon slave unit
-- PWM with programmable period, duty cycle and polarity
-- 
-- 5 address:
--   0x00: time base register
--   0x01: period register
--   0x02: duty cycle register
--	 0x03: polarity register
--   0x04: control register

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY PWM IS
   PORT(
		nReset	: IN std_logic;
		Clk		: IN std_logic;
		Addr	: IN std_logic_vector (3 DOWNTO 0);
		R		: IN std_logic;
		W		: IN std_logic;
		RData	: OUT std_logic_vector (15 DOWNTO 0);
		WData	: IN std_logic_vector (15 DOWNTO 0);
		PWMOut	: OUT std_logic
);
END PWM;

ARCHITECTURE bhv OF PWM IS
	signal		iRegClkD	: std_logic_vector (1 DOWNTO 0);	-- internal time base register
	signal		iRegPeriod	: std_logic_vector (15 DOWNTO 0);	-- internal period register
	signal		iRegDuty	: std_logic_vector (15 DOWNTO 0);	-- internal duty cycle register
	signal		iRegPol		: std_logic;	-- internal polarity register
	signal		iRegCount	: std_logic_vector (15 DOWNTO 0);	-- internal counter register
	signal		iRegCtrl	: std_logic;	-- internal control register
	signal		iRegRead	: std_logic;	-- internal read register
	signal		iRegEnable	: boolean := false;	-- internal enable register
	signal		iRegOut		: boolean := false;	-- internal out register
	variable 	i			: integer := '0';
	variable	tbase		: integer := '1';

BEGIN

-- Process to write internal registers through Avalon bus interface
-- Synchronous access in rising_edge of clk
WriteProcess:
	Process(nReset, Clk)
	Begin
	if nReset = '0' then
        iRegClkD	<= (others => '0');
		iRegPeriod	<= (others => '0');
		iRegDuty	<= (others => '0');
		iRegPol		<= (others => '0');
		iRegCount	<= (others => '0');
		iRegCtrl	<= (others => '0');
		iRegEnable	<= false;
		iRegOut		<= false;
		i := '0';
		tbase := '1';
	elsif rising_edge(Clk) then
		if W = '1' then
			case Addr is
				when "0000" => iRegClkD <= WData;
				when "0001" => iRegPeriod <= WData;
				when "0011" => iRegDuty <= WData;
				when "0101" => iRegPol <= WData;
				when "1001" => iRegCtrl <= WData;
				when others => null;
			end case;
		end if;
	end if;
   end process WriteProcess;

-- Process to wait 1 rising edge before reading the internal registers
WaitRead:
	Process(Clk)
	Begin
		if rising_edge(Clk) then
			iRegRead <= R;
		end if;
	end process WaitRead;

-- Process to read internal registers through Avalon bus interface
-- Synchronous access with 1 wait
ReadProcess:
	Process(iRegRead, Addr, iRegClkD, iRegPeriod, iRegDuty, iRegPol, iRegCount, iRegCtrl, iRegOut)
	Begin
	RDData <= (others => '0');
      if iRegRead = '1' then
			case Addr is
				when "0000" => RData <= iRegClkD;
				when "0001" => RData <= iRegPeriod;
				when "0011" => RData <= iRegDuty;
				when "0101" => RData <= iRegPol;
				when "0110" => RData <= iRegCount;
				when "1001" => RData <= iRegCtrl;
				when others => null;
			end case;
      end if;
   end process ReadProcess;

-- Process to compute the time base
TimeBase:
	Process(iRegClkD)
	Begin
		case iRegClkD is
			when "00" => tbase := '1'; -- Horloge de 50 MHz -> 20 ns, on ne peut pas descendre en dessous, donc à voir si on ne commencerait pas plutôt direct à la microseconde
			when "01" => tbase := "50"; -- 50 MHz/50 = 1 MHz -> 1 us
			when "10" => tbase := "50000"; -- 50 MHz/50000 = 1 kHz -> 1 ms
			when "11" => tbase := "50000000"; -- 50 MHz/50000000 = 1 Hz -> 1 s
		end case;
   end process TimeBase;
   
-- Process to divide the clock according to the time base
ClkDivider:
	Process(clk)
	Begin
		if rising_edge(clk) then
			i := i+1;
			iRegEnable <= false;
			if i = tbase then
				i := '0';
				iRegEnable <= true;
			end if;
		end if;
   end process ClkDivider;

-- Process to count the rising edges of the divided clock
Count:
	Process(iRegEnable)
	Begin
		if rising_edge(iRegEnable) then
			iRegCount <= iRegCount+1;
		end if;
	end process Count;

-- Process to reset i when it reaches the duty cycle and period values and to determine the stage
UpdateRegOut:
	Process(iRegCount, iRegDuty, iRegPeriod)
	Begin
		if iRegCount = iRegDuty*iRegPeriod then
			iRegCount <= (others => '0');
			iRegOut <= false;
		end if;
		if iRegCount = (1 - iRegDuty)*iRegPeriod then
			iRegCount <= (others => '0');
			iRegOut <= true;
		end if;
	end process UpdateRegOut;

-- Process to output the PWM
OutPWM:
	Process(iRegCtrl, iRegPol, iRegOut)
	Begin
		if iRegCtrl = '0' then
			PWMOut <= false;
		else
			if iRegPol = '0' then
				PWMOut <= iRegOut;
			else
				PWMOut <= not iRegOut;
			end if;
		end if;
	end process OutPWM;

END bhv;