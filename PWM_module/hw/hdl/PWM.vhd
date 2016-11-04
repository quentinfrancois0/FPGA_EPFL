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
		RData	: OUT std_logic_vector (7 DOWNTO 0);
		WData	: IN std_logic_vector (7 DOWNTO 0);
		PWMOut	: OUT std_logic
);
END PWM;

ARCHITECTURE bhv OF PWM IS
	signal		iRegClkD	: std_logic_vector (15 DOWNTO 0);	-- internal time base register
	signal		iRegCountEnable	: std_logic_vector (15 DOWNTO 0);	-- internal period register
	signal		iRegDuty	: std_logic_vector (7 DOWNTO 0);	-- internal duty cycle register
	signal		iRegPol		: std_logic;	-- internal polarity register
	signal		iRegCount	: std_logic_vector (7 DOWNTO 0);	-- internal counter register
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
		iRegCountEnable	<= (others => '0');
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
				when "0010" => iRegCountEnable <= WData;
				when "0100" => iRegDuty <= WData;
				when "0101" => iRegPol <= WData;
				when "1000" => iRegCtrl <= WData;
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
				when "0010" => RData <= iRegCountEnable;
				when "0100" => RData <= iRegDuty;
				when "0101" => RData <= iRegPol;
				when "0110" => RData <= iRegCount;
				when "1000" => RData <= iRegCtrl;
				when others => null;
			end case;
      end if;
   end process ReadProcess;

-- Process to compute divide the clock
ClkDivider:
	Process(Clk)
	Begin
		if rising_edge(clk) then	
			if iRegCountEnable < iRegClkD then
				iRegCountEnable <= iRegCountEnable+1;
			elsif  iRegCountEnable = iRegClkD then
				iRegCount <= iRegCount+1;
				iRegCountEnable <= '0';
			else
				iRegCountEnable <= '0';
			end if;
		end if;
	end process ClkDivider;

-- Process to reset i when it reaches the duty cycle and period values and to determine the stage
UpdateRegOut:
	Process(iRegCount, iRegDuty, iRegPeriod)
	Begin
		if iRegCount < iRegDuty then
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