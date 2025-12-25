LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Controller IS
    	GENERIC (N : integer := 13);
    	PORT (
        	clk 	: IN  std_logic;
            	rst 	: IN  std_logic;
            	start   : IN  std_logic;
            
            	Sel     : OUT std_logic;
            	En      : OUT std_logic;
		exp_ld  : OUT std_logic;
            	i	: OUT integer RANGE 1 TO N;
            	done    : OUT std_logic
    	);
END Controller;

ARCHITECTURE Behavioral OF Controller IS
	TYPE State_type IS (S0, S1, S2, S3);
	SIGNAL State : State_type;
	SIGNAL i_calc : integer RANGE 1 TO N;

BEGIN
	i <= i_calc;

	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			State <= S0;
			i_calc <= 1;
		ELSIF (clk'EVENT AND clk = '1') THEN
			CASE State IS
				WHEN S0 =>
					IF (start = '1') THEN
						State <= S1;
					END IF;
				WHEN S1 =>
					i_calc <= 1;
					State <= S2;
				WHEN S2 =>
					IF (i_calc < N) THEN
						i_calc <= i_calc + 1;
						State <= S2;
					ELSE
						State <= S3;
					END IF;
				WHEN S3 =>
					State <= S0;
				WHEN OTHERS =>
					State <= S0;
			END CASE;
		END IF;
	END PROCESS;

	Sel <= '1' WHEN (State = S1) ELSE '0';
	En <= '1' WHEN (State = S1 OR State = S2) ELSE '0';
	exp_ld <= '1' WHEN (State = S3) ELSE '0';
	done <= '1' WHEN (State = S3) ELSE '0';
END Behavioral;
