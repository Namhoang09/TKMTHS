LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Controller IS
    	GENERIC (N : integer := 13);
    	PORT (
        		clk 	: IN  std_logic;
            	rst 	: IN  std_logic;
            	start   : IN  std_logic;
				zero	: IN  std_logic;
            
            	Sel     : OUT std_logic;
            	En      : OUT std_logic;
            	exp_ld  : OUT std_logic;
            	i		: OUT integer RANGE 1 TO N;
            	done    : OUT std_logic
    	);
END Controller;

ARCHITECTURE Behavioral OF Controller IS
	TYPE State_type IS (S0, S1, S2, S3, S4);
	SIGNAL state_reg, state_next : State_type;
    SIGNAL i_reg, i_next         : integer RANGE 1 TO N;
    SIGNAL rep_reg, rep_next     : std_logic;

BEGIN
		i <= i_reg;

    	PROCESS(clk, rst)
    	BEGIN
        	IF (rst = '1') THEN
            		state_reg <= S0;
            		i_reg     <= 1;
            		rep_reg   <= '0';
        	ELSIF (clk'EVENT AND clk = '1') THEN
            		state_reg <= state_next;
            		i_reg     <= i_next;
            		rep_reg   <= rep_next;
        	END IF;
    	END PROCESS;

    	PROCESS(state_reg, i_reg, rep_reg, start, zero)
    	BEGIN
        	state_next <= state_reg;
        	i_next     <= i_reg;
        	rep_next   <= rep_reg;

        	CASE state_reg IS
            		WHEN S0 =>
                		i_next   <= 1;       
                		rep_next <= '0';
                        IF (start = '1') THEN
                    			state_next <= S1;
                		END IF;

            		WHEN S1 =>
                		IF (zero = '1') THEN
                    			state_next <= S3;
                		ELSE
                    			state_next <= S2;
                		END IF;

            		WHEN S2 =>
                		IF ((i_reg = 4 OR i_reg = 13) AND rep_reg = '0') THEN
                    			i_next     <= i_reg; 
                    			rep_next   <= '1'; 
                    			state_next <= S2; 
                		ELSIF (i_reg < N) THEN
                    			i_next     <= i_reg + 1;
                    			rep_next   <= '0'; 
                    			state_next <= S2;   
                		ELSE
                    			state_next <= S3; 
                		END IF;

            		WHEN S3 =>
                		state_next <= S4;

            		WHEN S4 =>
                		state_next <= S0;

            		WHEN OTHERS =>
                		state_next <= S0;
        	END CASE;
    	END PROCESS;

    	Sel    <= '1' WHEN (state_reg = S1) ELSE '0';
    	En     <= '1' WHEN (state_reg = S1 OR state_reg = S2) ELSE '0';
    	exp_ld <= '1' WHEN (state_reg = S3) ELSE '0';
    	done   <= '1' WHEN (state_reg = S4) ELSE '0';
END Behavioral;

