LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.Mylib.all;

ENTITY ExpApprox IS
    	GENERIC (
		DATA_WIDTH 	: integer := 16; 
		N 		: integer := 13
	);

    	PORT (
        	clk 	: IN  std_logic;
            	rst 	: IN  std_logic;
            	start   : IN  std_logic;
        	t     	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

		done 	: OUT std_logic;
        	exp  	: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
    	);
END ExpApprox;

ARCHITECTURE Structure OF ExpApprox IS
	SIGNAL Sel 	: std_logic;
	SIGNAL En	: std_logic;
	SIGNAL i	: integer RANGE 1 TO N;
	SIGNAL exp_ld 	: std_logic; 
	SIGNAL zero 	: std_logic; 
BEGIN
	CTRL : Controller
		GENERIC MAP (N)
		PORT MAP (clk, rst, start, zero, Sel, En, exp_ld, i, done);

	DTP: Datapath
		GENERIC MAP (DATA_WIDTH, N)
		PORT MAP(clk, rst, Sel, En, exp_ld, i, t, zero, exp);
END Structure;
