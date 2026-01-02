LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Cordic_stage IS
    	GENERIC (DATA_WIDTH : integer := 16);

    	PORT (
        	X	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        	Y	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        	Z	: IN  signed(DATA_WIDTH-1 DOWNTO 0);
        	lut     : IN  signed(DATA_WIDTH-1 DOWNTO 0);
		i       : IN  integer;

        	X_out 	: OUT signed(DATA_WIDTH-1 DOWNTO 0);
        	Y_out	: OUT signed(DATA_WIDTH-1 DOWNTO 0);
        	Z_out 	: OUT signed(DATA_WIDTH-1 DOWNTO 0)
    	);
END Cordic_stage;

ARCHITECTURE Behavioral OF Cordic_stage IS
BEGIN
    	PROCESS(X, Y, Z, i, lut)
        	VARIABLE X_shift : signed(DATA_WIDTH-1 DOWNTO 0);
        	VARIABLE Y_shift : signed(DATA_WIDTH-1 DOWNTO 0);
    	BEGIN
        	X_shift := shift_right(X, i);
        	Y_shift := shift_right(Y, i);

        	IF (Z >= 0) THEN
            		X_out <= X + Y_shift;
            		Y_out <= Y + X_shift;
            		Z_out <= Z - lut;
        	ELSE
            		X_out <= X - Y_shift;
            		Y_out <= Y - X_shift;
            		Z_out <= Z + lut;
        	END IF;
    	END PROCESS;
END Behavioral;
