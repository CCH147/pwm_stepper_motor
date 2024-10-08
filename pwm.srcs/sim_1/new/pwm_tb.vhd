LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.constant_def.all;

ENTITY stepper_motor_tb IS
END stepper_motor_tb;
 
ARCHITECTURE behavior OF stepper_motor_tb IS 
    COMPONENT stepper_motor
    Port ( clk              : in STD_LOGIC;
           rst              : in STD_LOGIC;
           th_speed         : in  STD_LOGIC_VECTOR (6 downto 0);
           target_speed     : in  STD_LOGIC_VECTOR (6 downto 0); 
           speed_now        : inout STD_LOGIC_VECTOR (6 downto 0);
           btn              : in STD_LOGIC;
           pwm              : out STD_LOGIC
           
           );
    END COMPONENT;
    

   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal btn : std_logic := '0';
   signal speed_now   : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
   signal th_speed    : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
   signal target_speed      : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
   signal pwm           : STD_LOGIC;


   constant clk_period : time := 10 ns;
 
BEGIN
 
	
   uut: stepper_motor PORT MAP (
          clk => clk,
          rst => rst,
          th_speed => th_speed,
          target_speed => target_speed,
          btn => btn,
          speed_now => speed_now,
          pwm => pwm
        );


   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   process
   begin		
    wait for clk_period;
    rst <= '0';
    btn  <= '0';
    wait for clk_period*2;
    rst <= '1';
    wait for clk_period*3;
    rst <= '0';
    --speed_now <= "0000001"; -- 1
    th_speed <= "1010000";  -- 80
    target_speed <= "1100100";    -- 100

    wait for clk_period*2;
    btn  <= '1';
    wait for clk_period*1000000;
   end process;

END;
