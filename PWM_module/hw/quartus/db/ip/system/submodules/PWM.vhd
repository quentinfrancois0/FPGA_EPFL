-- Design of a PWM module
-- Avalon slave unit
-- 
-- Authors : Nicolas Berling & Quentin François
-- Date : 10.11.2016
--
-- PWM with programmable period, duty cycle and polarity
--
-- 5 address :
-- 	0x00: clock divider register
-- 	0x02: duty cycle register
-- 	0x03: polarity register
-- 	0x04: counter register
-- 	0x05: control register

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY PWM IS
	PORT(
		nReset	: IN std_logic;							-- nReset input
		Clk		: IN std_logic;							-- clock input
		Addr	: IN std_logic_vector (2 DOWNTO 0);		-- address bus
		R		: IN std_logic;							-- read enabler
		W		: IN std_logic;							-- write enabler
		RData	: OUT std_logic_vector (7 DOWNTO 0);	-- data bus (read)
		WData	: IN std_logic_vector (7 DOWNTO 0);		-- data bus (write)
		PWMOut	: OUT std_logic							-- PWM output
	);
END PWM;

ARCHITECTURE bhv OF PWM IS
	signal		iRegClkD		: std_logic_vector (15 DOWNTO 0);	-- internal clock divider register
	signal		iRegDuty		: std_logic_vector (7 DOWNTO 0);	-- internal duty cycle register
	signal		iRegPol			: std_logic_vector (7 DOWNTO 0);	-- internal polarity register
	signal		iRegCount		: std_logic_vector (7 DOWNTO 0);	-- internal counter register
	signal		iRegCtrl		: std_logic_vector (7 DOWNTO 0);	-- internal control register
	signal		iRegOut			: std_logic;						-- internal phantom out register
	signal		iRegCountEnable	: std_logic_vector (15 DOWNTO 0);	-- internal phantom counter enabler register
	signal		iRegRead		: std_logic;						-- internal phantom read register

BEGIN

-- Process to write internal registers through Avalon bus interface
-- Synchronous access on rising edge of the FPGA's clock
WriteProcess:
Process(nReset, Clk)
Begin
	if nReset = '0' then	-- reset the four writable registers when pushing the reset key
        iRegClkD		<= (others => '0');
		iRegDuty		<= (others => '0');
		iRegPol			<= (others => '0');
		iRegCtrl		<= (others => '0');
	elsif rising_edge(Clk) then
		if W = '1' then
			case Addr is
				when "000" => iRegClkD (7 DOWNTO 0) <= WData;
				when "001" => iRegClkD (15 DOWNTO 8) <= WData;
				when "010" => iRegDuty <= WData;
				when "011" => iRegPol <= WData;
				when "101" => iRegCtrl <= WData;
				when others => null;
			end case;
		end if;
	end if;
end process WriteProcess;

-- Process to wait one rising edge before reading the internal registers
WaitRead:
Process(nReset, Clk)
Begin
	if nReset = '0' then	-- reset the internal phantom read register when pushing the reset key
		iRegRead <= '0';
	elsif rising_edge(Clk) then
		iRegRead <= R;
	end if;
end process WaitRead;

-- Process to read internal registers through Avalon bus interface
-- Synchronous access on rising edge of the FPGA's clock with 1 wait
ReadProcess:
Process(iRegRead, Addr, iRegClkD, iRegDuty, iRegPol, iRegCount, iRegCtrl)
Begin
	RData <= (others => '0');	-- reset the data bus (read) when not used
	if iRegRead = '1' then
		case Addr is
			when "000" => RData <= iRegClkD (7 DOWNTO 0);
			when "001" => RData <= iRegClkD (15 DOWNTO 8);
			when "010" => RData <= iRegDuty;
			when "011" => RData <= iRegPol;
			when "100" => RData <= iRegCount;
			when "101" => RData <= iRegCtrl;
			when others => null;
		end case;
	end if;
end process ReadProcess;

-- Process to divide the clock and to increment the internal counter register
ClkDivider:
Process(nReset, Clk)
Begin
	if nReset = '0' then	-- reset the internal counter register and internal phantom counter enabler register when pushing the reset key
		iRegCount		<= (others => '0');
		iRegCountEnable	<= (others => '0');
	elsif rising_edge(clk) then
		if iRegCountEnable < iRegClkD then	-- divide the clock according to the value stored in the internal clock divider register
			iRegCountEnable <= std_logic_vector(unsigned(iRegCountEnable) + 1);
		elsif  iRegCountEnable = iRegClkD then	-- manage the internal counter register when the internal phantom counter enabler register reaches the value stored in the internal clock divider register
			if iRegCount = X"ff" then	-- reset the internal counter register if it is full
				iRegCount <= (others => '0');
			else	-- increment the internal counter register
				iRegCount <= std_logic_vector(unsigned(iRegCount) + 1);
			end if;
			iRegCountEnable <= (others => '0');	-- reset the internal phantom counter enabler register after the management of the internal counter register
		else	-- reset the internal phantom counter enabler register if it is bigger than the internal clock divider register
			iRegCountEnable <= (others => '0');
		end if;
	end if;
end process ClkDivider;

-- Process to update the output
UpdateRegOut:
Process(iRegCount, iRegDuty, iRegPol)
Begin
	if iRegCount <= iRegDuty then	-- set the internal phantom out register according to the polarity
		iRegOut <= iRegPol(0);
	elsif iRegCount > iRegDuty then	-- reset the internal phantom out register according to the polarity
		iRegOut <= not iRegPol(0);
	else	-- otherwise, reset the internal phantom out register
		iRegOut	<= '0';
	end if;
end process UpdateRegOut;

-- Process to output the PWM
OutPWM:
Process(iRegCtrl, iRegOut)
Begin
	if iRegCtrl = X"00" then	-- reset the output if the internal control register is equal to 0
		PWMOut <= '0';
	else	-- otherwise, copy the internal phantom out register on the output
		PWMOut <= iRegOut;
	end if;
end process OutPWM;

END bhv;