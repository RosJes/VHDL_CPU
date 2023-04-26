library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;

-- VHDL code for ALU of the MIPS Processor
entity ALU_module is
port(
  Clk             :   in std_logic;
 Reset_n          :   in std_logic;
 a,b              :   in std_logic_vector(7 downto 0); -- src1, src2
 alu_control      :   in std_logic_vector(2 downto 0); -- function select
 alu_result       :   out std_logic_vector(7 downto 0) ; -- ALU Output Result
 zero             :   out std_logic; -- Zero Flag
 EO               :   in std_logic
 );
end ALU_module;
architecture rtl of ALU_module is
signal comparator :std_logic_vector(7 downto 0);
signal result : unsigned(7 downto 0) := (others => '0');
  begin
   comparator <= "00000001" when unsigned(a)>unsigned(b) else (others => '0') ;
    process(alu_control,a,b)
    begin
        case alu_control is
        when "000" =>
          result <= unsigned(a)+unsigned(b); -- add
        when "001" =>
        result <= unsigned(a)-unsigned(b); -- sub
       when "010" => --comparator
         result <= unsigned(comparator);
       when "011" =>
         result <= unsigned(a) or unsigned(b) ; -- or
        when others => result <= unsigned(a)+unsigned(b); -- add
        end case;
        end process;
       zero <= '1' when result=x"0000" else '0';
       alu_result <= std_logic_vector(result);
end rtl;