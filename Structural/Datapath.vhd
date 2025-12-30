LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Mylib.all;

ENTITY Datapath IS
	GENERIC (
		DATA_WIDTH 	: integer := 16;
		N		: integer := 13
	);

	PORT (
		clk 	: IN  std_logic;
            	rst 	: IN  std_logic;
            	Sel 	: IN  std_logic;
            	En      : IN  std_logic;
            	exp_ld  : IN  std_logic;
            	i	: IN  integer RANGE 1 TO N;            
            	t       : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

		zero    : OUT std_logic;
            	exp     : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)

	);
END Datapath;

ARCHITECTURE Structural OF Datapath IS
	CONSTANT INV_K : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(INV_K_VAL, DATA_WIDTH);
	CONSTANT ONE   : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(ONE_VAL, DATA_WIDTH);

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
	
	SIGNAL X, X_calc : signed(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Y, Y_calc : signed(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Z, Z_calc : signed(DATA_WIDTH-1 DOWNTO 0);

	SIGNAL X_cur, X_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Y_cur, Y_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Z_cur, Z_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

	SIGNAL is_zero : std_logic;
	SIGNAL exp_calc : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
BEGIN
	is_zero <= '1' WHEN (signed(t) = 0) ELSE '0';
	zero    <= is_zero;

	X_next <= std_logic_vector(INV_K) WHEN Sel = '1' ELSE std_logic_vector(X_calc);
	Y_next <= (OTHERS => '0') 	  WHEN Sel = '1' ELSE std_logic_vector(Y_calc);
	Z_next <= t 			  WHEN Sel = '1' ELSE std_logic_vector(Z_calc);

	X <= signed(X_cur);
	Y <= signed(Y_cur);
	Z <= signed(Z_cur);

	PROCESS(X, Y, Z, i)
		VARIABLE X_shift: signed(DATA_WIDTH-1 DOWNTO 0);
		VARIABLE Y_shift: signed(DATA_WIDTH-1 DOWNTO 0);
	BEGIN
		X_shift := shift_right(X, i);
		Y_shift := shift_right(Y, i);

		IF (Z >= 0) THEN
			X_calc <= X + Y_shift;
			Y_calc <= Y + X_shift;
			Z_calc <= Z - LUT(i);
		ELSE
			X_calc <= X - Y_shift;
			Y_calc <= Y - X_shift;
			Z_calc <= Z + LUT(i);
		END IF;
	END PROCESS;

	exp_calc <= std_logic_vector(ONE) WHEN (is_zero = '1') ELSE std_logic_vector(X + Y);

	RegX: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, X_next, X_cur);
    	RegY: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Y_next, Y_cur);
    	RegZ: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Z_next, Z_cur);

	RegExp: Reg_n
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, exp_ld, exp_calc, exp);
END Structural;
