library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity T_CPU is
end entity;

architecture test of T_CPU is
    signal Clk, rst_n   :std_logic;
    signal HEX0      : std_logic_vector(6 DOWNTO 0);
    signal HEX1      : std_logic_vector(6 DOWNTO 0);
    signal HEX_IR_1						: std_logic_vector (6 downto 0);
    signal HEX_IR_2						:	 std_logic_vector (6 downto 0);
    signal HEX_IR_3						:	std_logic_vector (6 downto 0);
    signal HEX_IR_4						:   std_logic_vector (6 downto 0);
    signal key       : std_logic_vector(0 downto 0);
    component CPU
    port(
        Clk,rst_n                   :   in std_logic;
        Key                         :   in std_logic_vector(0 downto 0);
		  HEX_IR_1						: 	out std_logic_vector (6 downto 0);
		  HEX_IR_2						:	out std_logic_vector (6 downto 0);
		  HEX_IR_3						:	out std_logic_vector (6 downto 0);
		  HEX_IR_4						:  out std_logic_vector (6 downto 0);
        HEX0                        :   out std_logic_vector(6 DOWNTO 0);
        HEX1                        :   out std_logic_vector(6 DOWNTO 0)
    );
    end component;
    begin
        UUT: CPU port map(
            Clk => Clk,
            rst_n => rst_n,
            key => key,
            HEX_IR_1 => HEX_IR_1,	
            HEX_IR_2 => HEX_IR_2,	
            HEX_IR_3 => HEX_IR_3,	
            HEX_IR_4	=> HEX_IR_4,
            HEX0 => HEX0,
            HEX1 => HEX1
        );
        clock:process 
        begin
            Clk <= '0';
            wait for 10 ns;
            Clk <= '1';
            wait for 10 ns;
        end process;

        test: process 
        begin
            rst_n <= '0';
            wait for 40 ns;
            rst_n <= '1';
            wait;
        end process;
    end test;