LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ExpApprox IS
    	GENERIC (
        	DATA_WIDTH 	: integer := 16;
        	N     		: integer := 13
    	);

    	PORT (
        	clk      : IN  std_logic;
        	rst      : IN  std_logic;
        	start    : IN  std_logic;
        	t        : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

        	done     : OUT std_logic;
        	exp      : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
    	);

END ExpApprox;

ARCHITECTURE Behavioral OF ExpApprox IS
    	CONSTANT K_INV : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(9892, DATA_WIDTH);

    	TYPE lut_type IS ARRAY (1 TO N) OF signed(DATA_WIDTH-1 DOWNTO 0);
    	CONSTANT LUT : lut_type := (
        	to_signed(4500, 16), -- i=1
        	to_signed(2092, 16), -- i=2
        	to_signed(1029, 16), -- i=3
        	to_signed(513, 16),  -- i=4
        	to_signed(256, 16),  -- i=5
        	to_signed(128, 16),  -- i=6
        	to_signed(64, 16),   -- i=7
        	to_signed(32, 16),   -- i=8
        	to_signed(16, 16),   -- i=9
        	to_signed(8, 16),    -- i=10
        	to_signed(4, 16),    -- i=11
        	to_signed(2, 16),    -- i=12
        	to_signed(1, 16)     -- i=13
    	);

    	SIGNAL X, Y, Z : signed(DATA_WIDTH-1 DOWNTO 0);
    	SIGNAL X_next, Y_next, Z_next : signed(DATA_WIDTH-1 DOWNTO 0);
    	SIGNAL i : integer RANGE 1 TO N;
    
    	TYPE state_type IS (IDLE, INIT, CALC, FINISH);
    	SIGNAL current_state, next_state : state_type;
	SIGNAL repeat_done : std_logic;

BEGIN

    	PROCESS(clk, rst)
    	BEGIN
        	IF (rst = '1') THEN
            		current_state <= IDLE;
			X <= (OTHERS => '0');
        		Y <= (OTHERS => '0');
        		Z <= (OTHERS => '0');
            		i <= 1;
			repeat_done <= '0';
       		ELSIF (clk'EVENT AND clk = '1') THEN
            		IF (current_state = INIT) THEN
                		IF (signed(t) = 0) THEN
        				X <= to_signed(8192, DATA_WIDTH);
        				Y <= (OTHERS => '0');
        				Z <= (OTHERS => '0');
        				i <= N; 
    				ELSE
        				X <= K_INV;           -- X = 1/K 
        				Y <= (OTHERS => '0'); -- Y = 0
        				Z <= signed(t);       -- Z = t
        				i <= 1;
    				END IF;
				repeat_done <= '0';
            		ELSIF (current_state = CALC) THEN
				X <= X_next;
                		Y <= Y_next;
                		Z <= Z_next;

				IF ((i = 4 OR i = 13) AND repeat_done = '0') THEN
					i <= i;
					repeat_done <= '1';
				ELSIF (i < N) THEN
                    			i <= i + 1;
					repeat_done <= '0';
                		END IF;
            		END IF;

			current_state <= next_state;
        	END IF;
    	END PROCESS;

    	PROCESS(current_state, start, i, X, Y, Z, t)
        	VARIABLE shift_x, shift_y : signed(DATA_WIDTH-1 DOWNTO 0);
    	BEGIN
		next_state <= current_state;
        	done <= '0';
        	exp <= (OTHERS => '0');
        
        	shift_x := shift_right(X, i);
        	shift_y := shift_right(Y, i);
        
        	X_next <= X;
        	Y_next <= Y;
        	Z_next <= Z;

        	CASE current_state IS
            		WHEN IDLE =>
                		IF (start = '1') THEN
                    			next_state <= INIT;
                		END IF;

            		WHEN INIT =>
                		IF (signed(t) = 0) THEN
            				next_state <= FINISH;
        			ELSE
            				next_state <= CALC;
        			END IF;

            		WHEN CALC =>
				IF (N = 4 OR N = 13) THEN
					IF (i = N AND repeat_done = '1') THEN
						next_state <= FINISH;
					ELSE
						next_state <= CALC;
					END IF;
				ELSE
					IF (i = N) THEN
						next_state <= FINISH;
					ELSE
						next_state <= CALC;
					END IF;
				END IF;

				IF (Z > 0) THEN
                        		X_next <= X + shift_y;       	-- X + Y*2^-i
                        		Y_next <= Y + shift_x;       	-- Y + X*2^-i
                        		Z_next <= Z - LUT(i);  		-- Z - LUT[i]
                   		ELSE
                        		X_next <= X - shift_y;
                        		Y_next <= Y - shift_x;
                        		Z_next <= Z + LUT(i);
                    		END IF;

            		WHEN FINISH =>
				done <= '1';
				exp <= std_logic_vector(X + Y);
                		 
                		IF (start = '0') THEN
                    			next_state <= IDLE;
                		END IF;
        	END CASE;
    	END PROCESS;
END Behavioral;
