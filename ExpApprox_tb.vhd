LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ExpApprox_tb IS
END ExpApprox_tb;

ARCHITECTURE Behavioral OF ExpApprox_tb IS
    	COMPONENT ExpApprox
        	GENERIC (
            		DATA_WIDTH  	: integer := 16;
            		N		: integer := 13
        	);

        	PORT (
            		clk      : IN  std_logic;
            		rst      : IN  std_logic;
            		start    : IN  std_logic;
            		t        : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
            		done     : OUT std_logic;
            		exp      : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
        	);
    	END COMPONENT;

    	SIGNAL clk      : std_logic := '0';
    	SIGNAL rst      : std_logic := '0';
    	SIGNAL start    : std_logic := '0';
    	SIGNAL t        : std_logic_vector(15 downto 0) := (others => '0');
    	SIGNAL done     : std_logic;
    	SIGNAL exp      : std_logic_vector(15 downto 0);

        CONSTANT CLK_PERIOD : time := 10 ns;

BEGIN
    UUT: ExpApprox
        PORT MAP (
            clk      => clk,
            rst      => rst,
            start    => start,
            t        => t,
            done     => done,
            exp      => exp
        );

    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD/2;
        clk <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;

    stim_proc: PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 20 ns;
        rst <= '0';
        WAIT FOR 20 ns;

        -- TEST 1: t = 1
        t <= std_logic_vector(to_signed(8192, 16)); 
        start <= '1';
        WAIT FOR CLK_PERIOD;
        start <= '0';
        
        WAIT UNTIL done = '1';
        WAIT FOR 20 ns; 

        -- TEST 2: t = 0.5
        t <= std_logic_vector(to_signed(4096, 16));
        start <= '1';
        WAIT FOR CLK_PERIOD;
        start <= '0';
        
        WAIT UNTIL done = '1';
        WAIT FOR 20 ns;

        -- TEST 3: t = -0.5
        t <= std_logic_vector(to_signed(-4096, 16));
        start <= '1';
        WAIT FOR CLK_PERIOD;
        start <= '0';
        
        WAIT UNTIL done = '1';
        WAIT FOR 20 ns;
        
        -- TEST 4: t = 0
        t <= std_logic_vector(to_signed(0, 16));
        start <= '1';
        WAIT FOR CLK_PERIOD;
        start <= '0';
        
        WAIT UNTIL done = '1';
        WAIT FOR 20 ns;

        WAIT;
    END PROCESS;
END Behavioral;
