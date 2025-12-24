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
        rst_n    : IN  std_logic;
        start    : IN  std_logic;
        t_in     : IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
        done     : OUT std_logic;
        exp_out  : OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
    );

END ExpApprox;

ARCHITECTURE Behavioral OF ExpApprox IS
    CONSTANT FRAC_BITS : integer := 13;
    CONSTANT K_INV : signed(DATA_WIDTH-1 DOWNTO 0) := to_signed(9872, DATA_WIDTH);

    type lut_type is array (1 to N) of signed(DATA_WIDTH-1 downto 0);
    constant ATANH_LUT : lut_type := (
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

    -- Các thanh ghi n?i b?
    signal X, Y, Z : signed(DATA_WIDTH-1 downto 0);
    signal X_next, Y_next, Z_next : signed(DATA_WIDTH-1 downto 0);
    signal i : integer range 1 to N + 1;
    
    -- Tr?ng thái FSM
    type state_type is (IDLE, INIT, CALC, FINISH);
    signal current_state, next_state : state_type;

begin

    -- 1. Sequential Logic: Chuy?n tr?ng thái
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            current_state <= IDLE;
            X <= (others => '0');
            Y <= (others => '0');
            Z <= (others => '0');
            i <= 1;
        elsif (clk'EVENT AND clk = '1') then
            current_state <= next_state;
            -- C?p nh?t thanh ghi d? li?u
            if (current_state = INIT) then
                X <= K_INV;           -- X = 1/K 
                Y <= (others => '0'); -- Y = 0
                Z <= signed(t_in);    -- Z = t
                i <= 1;
            elsif (current_state = CALC) then
                X <= X_next;
                Y <= Y_next;
                Z <= Z_next;
                if i <= N then
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;

    -- 2. Combinational Logic: ?i?u khi?n tr?ng thái & Tính toán (ALU)
    process(current_state, start, i, X, Y, Z, t_in)
        variable shift_x, shift_y : signed(DATA_WIDTH-1 downto 0);
    begin
        -- Default assignments
        next_state <= current_state;
        done <= '0';
        exp_out <= (others => '0');
        
        -- Shift operations (Arithmetic shift right)
        shift_x := shift_right(X, i);
        shift_y := shift_right(Y, i);
        
        -- Logic tính toán m?c ??nh
        X_next <= X;
        Y_next <= Y;
        Z_next <= Z;

        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= INIT;
                end if;

            when INIT =>
                next_state <= CALC;

            when CALC =>
                if i > N then
                    next_state <= FINISH;
                else
                    -- Thu?t toán CORDIC Hyperbolic 
                    if Z >= 0 then
                        X_next <= X + shift_y;       -- X + Y*2^-i
                        Y_next <= Y + shift_x;       -- Y + X*2^-i
                        Z_next <= Z - ATANH_LUT(i);  -- Z - LUT[i]
                    else
                        X_next <= X - shift_y;
                        Y_next <= Y - shift_x;
                        Z_next <= Z + ATANH_LUT(i);
                    end if;
                    next_state <= CALC;
                end if;

            when FINISH =>
                done <= '1';
                -- K?t qu? e^t = X + Y 
                exp_out <= std_logic_vector(X + Y); 
                if start = '0' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;

end Behavioral;
