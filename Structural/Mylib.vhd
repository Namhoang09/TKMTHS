LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE Mylib IS
	CONSTANT INV_K_VAL : integer := 9892;
    	CONSTANT ONE_VAL   : integer := 8192;

	TYPE array_type IS ARRAY (1 TO 13) OF integer;
    	CONSTANT LUT_INT : array_type := (
        	4500, 2092, 1029, 513, 256, 128, 64, 
        	32, 16, 8, 4, 2, 1
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

    	COMPONENT Datapath IS
        	GENERIC (
			DATA_WIDTH 	: integer := 16;
			N 		: integer := 13
		);

        	PORT (
            		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		Sel 	: IN  std_logic;
            		En	: IN  std_logic;
			exp_ld  : IN  std_logic;
            		i	: IN  integer RANGE 1 TO N;            
            		t       : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

			zero    : OUT std_logic;
            		exp     : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
        	);
    	END COMPONENT;

    	COMPONENT Controller IS
        	GENERIC (N : integer := 13);

        	PORT (
            		clk 	: IN  std_logic;
            		rst 	: IN  std_logic;
            		start   : IN  std_logic;
			zero	: IN  std_logic;
            
            		Sel     : OUT std_logic;
            		En      : OUT std_logic;
            		exp_ld  : OUT std_logic;
            		i	: OUT integer RANGE 1 TO N;
            		done    : OUT std_logic
        	);
    	END COMPONENT;

	COMPONENT ExpApprox IS
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
	END COMPONENT;
END Mylib;
