LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Reg_n IS
    	GENERIC (DATA_WIDTH : integer := 16);

    	PORT (
        	clk : IN  std_logic;
        	rst : IN  std_logic;
        	En 	: IN  std_logic;
        	D 	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

        	Q 	: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
    	);
END Reg_n;

ARCHITECTURE REG OF Reg_n IS
BEGIN
    	PROCESS(clk, rst)
    	BEGIN
        	IF (rst = '1') THEN
            		Q <= (OTHERS => '0');
        	ELSIF (clk'EVENT AND clk = '1') THEN
            		IF (En = '1') THEN
                		Q <= D;
			--ELSE
				--Q <= (OTHERS => '0');
            		END IF;
        	END IF;
    	END PROCESS;
END REG;


