-- Design of a simple parallel port 
-- Avalon slave unit 
-- Parallel Port with programmable direction bit by bit on 8 bits 
-- 
-- 6 address: 
--   0: data direction
--   1: read
--   2: write
--	  3: pin register
--   4: set register
--   5: reset register

LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
-- USE ieee.std_logic_arith.all;
 
ENTITY Parallel_port IS 
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
END Parallel_port ;

ARCHITECTURE bhv OF Parallel_port IS
	signal      iRegDir     : std_logic_vector (7 DOWNTO 0);  -- internal direction register
	signal		iRegPort	: std_logic_vector (7 DOWNTO 0);  -- internal port register
	signal      iRegPin     : std_logic_vector (7 DOWNTO 0);  -- internal pin register
	signal      iRegRead    : std_logic;  -- internal read register

BEGIN
-- Process to write internal registers through Avalon bus interface
-- Synchronous access in rising_edge of clk
WriteReg:            -- Write by Avalon slave access 
   Process(Clk, nReset)
   Begin
	if nReset = '0' then
        iRegDir	<= (others => '0');  -- input at reset 
	elsif rising_edge(Clk) then
		if W = '1' then --Write
			case Addr is
				when "000" => iRegDir <= WRData;
				when "010" => iRegPort <= WRData;
				when "100" => iRegPort <= iRegPort OR WRData;
				when "101" => iRegPort <= iRegPort AND NOT WRData;
				when others => null;
			end case;
		end if;
	end if ;
   end process WriteReg ;
	
ReadReg:            -- Read by Avalon slave access 
   Process(iRegRead, Addr, iRegDir, PortP, iRegPin)
   Begin
		RDData <= (others => '0');
      if iRegRead = '1' then
			case Addr is
				when "000" => RDData <= iRegDir;
				when "001" => RDData <= PortP;
				when "011" => RDData <= iRegPin;
				when others => null;
			end case;
      end if ;
   end process ReadReg ;
   
ActRead:		--Temps d'attente pour read
	Process(Clk)
	Begin
		if rising_edge(Clk) then
			iRegRead <= R;
		end if;
	end process ActRead;
	
UpdatePort:
	Process (iRegDir, iRegPort)
	Begin
		for i in 0 to 7 loop
			if iRegDir(i) = '1' then
				PortP(i) <= iRegPort(i);
			else
				PortP(i) <= 'Z';
			end if;
		end loop;
   end process UpdatePort;
   
UpdateReadPin:
	Process (iRegRead, PortP)
	Begin
		iRegPin <= (others => '0');
		if iRegRead='1' then
			iRegPin <= PortP;
		end if;
	end process UpdateReadPin;
	
END bhv;