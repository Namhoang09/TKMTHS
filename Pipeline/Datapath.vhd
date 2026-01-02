LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Mylib.all;

ENTITY Datapath IS
	GENERIC (
		DATA_WIDTH 	: integer := 16;
		N			: integer := 13;
		NUM_STAGES 	: integer := 3
	);

	PORT (
				clk 	: IN  std_logic;
            	rst 	: IN  std_logic;
            	Sel 	: IN  std_logic;
            	En      : IN  std_logic;
            	exp_ld  : IN  std_logic;
            	phase	: IN  integer RANGE 1 TO (N + 2);            
            	t       : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

				zero    : OUT std_logic;
            	exp     : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
	);
END Datapath;

ARCHITECTURE Structural OF Datapath IS
	CONSTANT INV_K : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(INV_K_VAL, DATA_WIDTH);
	CONSTANT ONE   : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(ONE_VAL, DATA_WIDTH);

	CONSTANT NUM_PHASES : integer := (N + 2 + NUM_STAGES - 1) / NUM_STAGES;

	TYPE schedule_type IS ARRAY (1 TO NUM_PHASES, 1 TO NUM_STAGES) OF integer;
    FUNCTION init_matrix RETURN schedule_type IS
        	VARIABLE mat : schedule_type;
        	VARIABLE seq_idx : integer := 1;
    BEGIN
        	FOR p IN 1 TO NUM_PHASES LOOP
            		FOR s IN 1 TO NUM_STAGES LOOP
						IF (seq_idx <= N + 2) THEN
                			mat(p, s) := SEQ(seq_idx);
                			seq_idx := seq_idx + 1;
						ELSE
							mat(p, s) := DATA_WIDTH + 1;
						END IF;
            		END LOOP;
        	END LOOP;
        	RETURN mat;
    END FUNCTION;
    CONSTANT MATRIX : schedule_type := init_matrix;

	TYPE lut_type IS ARRAY (1 TO N) OF signed(DATA_WIDTH-1 DOWNTO 0);
    FUNCTION init_lut RETURN lut_type IS
        	VARIABLE temp_lut : lut_type;
    BEGIN
        	FOR k IN 1 TO N LOOP
            		temp_lut(k) := to_signed(LUT_INT(k), DATA_WIDTH);
        	END LOOP;
        	RETURN temp_lut;
    END FUNCTION;
    CONSTANT LUT : lut_type := init_lut;

	SIGNAL X_cur, X_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Y_cur, Y_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Z_cur, Z_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

	TYPE wire_vector IS ARRAY (0 TO NUM_STAGES) OF signed(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL X, Y, Z : wire_vector;

	SIGNAL is_zero 	: std_logic;
	SIGNAL exp_calc : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
BEGIN
	is_zero <= '1' WHEN (signed(t) = 0) ELSE '0';
	zero    <= is_zero;

	X_next <= std_logic_vector(INV_K) 	WHEN Sel = '1' ELSE std_logic_vector(X(NUM_STAGES));
    Y_next <= (OTHERS => '0') 	  		WHEN Sel = '1' ELSE std_logic_vector(Y(NUM_STAGES));
    Z_next <= t                       	WHEN Sel = '1' ELSE std_logic_vector(Z(NUM_STAGES));

	RegX: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, X_next , X_cur);
    RegY: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Y_next , Y_cur);
   	RegZ: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Z_next , Z_cur);

	X(0) <= signed(X_cur);
    Y(0) <= signed(Y_cur);
    Z(0) <= signed(Z_cur);

	Pipeline: FOR k IN 1 TO NUM_STAGES GENERATE
        	SIGNAL i : integer;
        	SIGNAL lut_val : signed(DATA_WIDTH-1 DOWNTO 0);
    BEGIN
        	PROCESS(phase)
				VARIABLE idx_val : integer;
        	BEGIN
				idx_val := MATRIX(phase, k);
            	i <= idx_val;
				IF (idx_val <= N) THEN
            		lut_val <= LUT(idx_val);
				ELSE
					lut_val <= (OTHERS => '0');
				END IF;
        	END PROCESS;

        	Stage_Inst: Cordic_stage 
            		GENERIC MAP (DATA_WIDTH)
            		PORT MAP (
                		X    	=> X(k-1), 
                		Y    	=> Y(k-1), 
                		Z    	=> Z(k-1),
                		lut 	=> lut_val,
                		i   	=> i,
                		X_out   => X(k),
                		Y_out   => Y(k),
                		Z_out   => Z(k)
            		);
    END GENERATE Pipeline;

	exp_calc <= std_logic_vector(ONE) WHEN (is_zero = '1') ELSE std_logic_vector(signed(X_cur) + signed(Y_cur));

	RegExp: Reg_n
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, exp_ld, exp_calc, exp);
END Structural;




