library IEEE;
use ieee.std_logic_1164.all;
package constant_def is
    constant full_speed       : integer := 80;
    constant max_speed       : integer := 8;
   -- constant sec_speed       : integer := 7;
    constant mid_speed       : integer := 5;
    --constant min_speed       : integer := 3;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.constant_def.all;

entity stepper_motor is
    Port ( clk              : in STD_LOGIC;
           rst              : in STD_LOGIC;
           th_speed         : in  STD_LOGIC_VECTOR (6 downto 0);
           target_speed     : in  STD_LOGIC_VECTOR (6 downto 0); 
           btn              : in STD_LOGIC;
           speed_now        : inout STD_LOGIC_VECTOR (6 downto 0);
           pwm              : out STD_LOGIC
           
           );
end stepper_motor;



architecture Behavioral of stepper_motor is

type speed_control_FSM is (high_speed,speedup,speeddown,steady,idle);
signal FSM                  : speed_control_FSM;
signal cnt1_clk,cnt2_clk      : std_logic;
signal cnt1,cnt2            : integer;
signal cnt1_max, cnt2_max   : integer; 

begin
out_process  : process(rst,clk,cnt1_clk,cnt2_clk)
begin
    pwm <= cnt1_clk;
    if rst = '1' then
        speed_now <= (others => '0');
    else
        if rising_edge(clk) then
            if cnt1_clk = '1' then
                speed_now <= speed_now + '1';
            elsif cnt2_clk = '1' then
                speed_now <= speed_now - '1';
            end if;
        end if;
    end if;
end process;

FSM_process  : process(btn,rst,speed_now,FSM)
begin
    if rst = '1' then
        FSM <= idle;
    else
        case FSM is
            when idle           =>
                if btn = '1' then
                    FSM <= high_speed;
                else
                    FSM <= idle ;
                end if;
            when high_speed    =>
                if speed_now >= th_speed and speed_now < target_speed then
                    FSM <= speedup;
                else
                    FSM <= high_speed;
                end if;
            when speedup        =>
                if speed_now > target_speed then
                    FSM <= speeddown;
                elsif speed_now = target_speed then
                    FSM <= steady;                       
                else
                    FSM <= speedup;
                end if; 
            when speeddown      =>
                if speed_now < target_speed then
                    if speed_now > th_speed then
                        FSM <= steady;
                    else
                        FSM <= speedup;
                    end if;                      
                else
                    FSM <= speeddown;
                end if;
            when steady         =>
                if speed_now > th_speed and speed_now < target_speed then
                    FSM <= steady;
                elsif speed_now > target_speed then
                    FSM <= speeddown;
                elsif speed_now < th_speed then
                    FSM <= speedup;
                end if;
            when others         =>
                FSM <= idle ;
        end case;
    end if;
end process;


cnt1_process : process(btn,clk,rst,cnt1_max,FSM,cnt1_clk,cnt1)
begin
    if rst = '1' then
        cnt1 <= 0;
        cnt2_clk <= '0';
    else
        case FSM is
            when idle           =>
            when high_speed     => cnt1_max <= full_speed;
            when speedup        => cnt1_max <= max_speed;
            when speeddown      => cnt1_max <= (10-max_speed);
            when steady         => cnt1_max <= mid_speed;
            when others         =>
        end case;
        if btn = '1' and cnt1_clk = '1' then
            cnt2_clk <= '0';
            if rising_edge(clk)then
                if cnt1 < cnt1_max then
                    cnt1 <= cnt1 + 1;
                else
                    cnt2_clk <= '1';
                end if;
            end if;
        else
            cnt1 <= 0;
        end if;
    end if;
end process;

cnt2_process : process(btn,clk,rst,cnt2_max,FSM,cnt2_clk,cnt2)
begin
    if rst = '1' then
        cnt2 <= 0;
        cnt1_clk <= '1';
    else
        case FSM is
            when idle           =>
            when high_speed     => cnt2_max <= 0;
            when speedup        => cnt2_max <= (10-max_speed);
            when speeddown      => cnt2_max <= (max_speed);
            when steady         => cnt2_max <= (10-mid_speed);
            when others         =>
        end case;
        if btn = '1' and cnt2_clk = '1' then
            cnt1_clk <= '0';
            if rising_edge(clk)then
                if cnt2 < cnt2_max then
                    cnt2 <= cnt2 + 1;
                else
                    cnt1_clk <= '1';        
                end if;
            end if;
        else
            cnt2 <= 0;
        end if;
    end if;
end process;

end Behavioral;
