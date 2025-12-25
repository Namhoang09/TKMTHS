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
        i		: IN  integer RANGE 1 TO N;            
        t       : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

        exp     : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)

	);
END Datapath;

ARCHITECTURE Structural OF Datapath IS
	CONSTANT INV_K : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(9872, DATA_WIDTH);
	TYPE lut_type IS ARRAY (1 TO N) OF signed(DATA_WIDTH-1 DOWNTO 0);
	CONSTANT LUT : lut_type := (
        	to_signed(4500, DATA_WIDTH), -- i=1
        	to_signed(2092, DATA_WIDTH), -- i=2
        	to_signed(1029, DATA_WIDTH), -- i=3
        	to_signed(513, DATA_WIDTH),  -- i=4
        	to_signed(256, DATA_WIDTH),  -- i=5
        	to_signed(128, DATA_WIDTH),  -- i=6
        	to_signed(64, DATA_WIDTH),   -- i=7
        	to_signed(32, DATA_WIDTH),   -- i=8
        	to_signed(16, DATA_WIDTH),   -- i=9
        	to_signed(8, DATA_WIDTH),    -- i=10
        	to_signed(4, DATA_WIDTH),    -- i=11
        	to_signed(2, DATA_WIDTH),    -- i=12
        	to_signed(1, DATA_WIDTH)     -- i=13
    	);
	
	SIGNAL X, X_calc : signed(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Y, Y_calc : signed(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Z, Z_calc : signed(DATA_WIDTH-1 DOWNTO 0);

	SIGNAL X_cur, X_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Y_cur, Y_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL Z_cur, Z_next : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

	--SIGNAL exp_calc : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

BEGIN

	X_next <= std_logic_vector(INV_K) WHEN Sel = '1' ELSE std_logic_vector(X_calc);
	Y_next <= (others => '0') 	  	  WHEN Sel = '1' ELSE std_logic_vector(Y_calc);
	Z_next <= t 			          WHEN Sel = '1' ELSE std_logic_vector(Z_calc);

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

		--exp_calc <= std_logic_vector(X_calc + Y_calc);
	END PROCESS;

	RegX: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, X_next, X_cur);
    RegY: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Y_next, Y_cur);
    RegZ: Reg_n 
		GENERIC MAP (DATA_WIDTH) 
		PORT MAP (clk, rst, En, Z_next, Z_cur);
	--RegExp: Reg_n
		--GENERIC MAP (DATA_WIDTH) 
		--PORT MAP (clk, rst, exp_ld, exp_calc, exp);
			
	exp <= std_logic_vector(X + Y) WHEN (exp_ld = '1') ELSE (others => '0');
END Structural;

