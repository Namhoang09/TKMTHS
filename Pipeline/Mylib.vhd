LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE Mylib IS
	CONSTANT INV_K_VAL : integer := 9892;
    	CONSTANT ONE_VAL   : integer := 8192;

	TYPE array_type IS ARRAY (1 TO 13) OF integer;
    	CONSTANT LUT_INT : array_type := (
        	4500, 2092, 1029, 513, 256, 128, 64, 
        	32, 16, 8, 4, 2, 1
    	);

	TYPE seq_array IS ARRAY (1 TO 15) OF integer;
    	CONSTANT SEQ : seq_array := (
        	1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13
    	);

    	COMPONENT Reg_n IS
        	GENERIC (DATA_WIDTH : integer := 16);

        	PORT (
            		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		En 	: IN  std_logic;
            		D 	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

            		Q 	: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
        	);
    	END COMPONENT;

	COMPONENT Cordic_stage IS
    		GENERIC (
			DATA_WIDTH 	: integer := 16; 
			N 		: integer := 13
		);

    		PORT (
        		X	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        		Y	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        		Z	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        		lut     : IN  signed(DATA_WIDTH-1 DOWNTO 0);
			i       : IN  integer RANGE 1 TO N;

        		X_out 	: OUT signed(DATA_WIDTH-1 DOWNTO 0);
        		Y_out	: OUT signed(DATA_WIDTH-1 DOWNTO 0);
        		Z_out 	: OUT signed(DATA_WIDTH-1 DOWNTO 0)
    		);
	END COMPONENT;

    	COMPONENT Datapath IS
        	GENERIC (
			DATA_WIDTH 	: integer := 16;
			N 		: integer := 13;
			NUM_STAGES 	: integer := 3
		);

        	PORT (
            		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		Sel 	: IN  std_logic;
            		En	: IN  std_logic;
			exp_ld  : IN  std_logic;
            		phase	: IN  integer RANGE 1 TO ((N + 2) / NUM_STAGES);            
            		t       : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

			zero    : OUT std_logic;
            		exp     : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
        	);
    	END COMPONENT;

    	COMPONENT Controller IS
        	GENERIC (
			N 		: integer := 13;
			NUM_STAGES 	: integer := 3
		);

        	PORT (
            		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		start   : IN  std_logic;
			zero	: IN  std_logic;
            
            		Sel     : OUT std_logic;
            		En      : OUT std_logic;
            		exp_ld  : OUT std_logic;
            		phase	: OUT integer RANGE 1 TO ((N + 2) / NUM_STAGES);
            		done    : OUT std_logic
        	);
    	END COMPONENT;

	COMPONENT ExpApprox IS
    		GENERIC (
			DATA_WIDTH 	: integer := 16; 
			N 		: integer := 13;
			NUM_STAGES 	: integer := 3
		);

    		PORT (
        		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		start   : IN  std_logic;
        		t     	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

			done 	: OUT std_logic;
        		exp  	: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
    		);
	END COMPONENT;
END Mylib;


