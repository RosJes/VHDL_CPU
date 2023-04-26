library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity hex_decoder_module is
    port(
        bus_vector_1            	:   	in std_logic_vector(7 downto 0);
        bus_vector_2            	:   	in std_logic_vector(7 downto 0);
  	IR_vector			:   	in std_logic_vector(3 downto 0);

  	HEX_IR_1			: 	out std_logic_vector (6 downto 0);
  	HEX_IR_2			:	out std_logic_vector (6 downto 0);
  	HEX_IR_3			:	out std_logic_vector (6 downto 0);
  	HEX_IR_4			:  	out std_logic_vector (6 downto 0);

  	HEX_OUT_1                	:   	out std_logic_vector (6 downto 0);
        HEX_OUT_2                	:   	out std_logic_vector (6 downto 0)
    );
end entity;

architecture rtl of hex_decoder_module is
--------hex displayer constants for FPGA MAX10-------------------------------
    	constant ZERO   :std_logic_vector(6 downto 0):=	"1000000";	
    	constant ONE    :std_logic_vector(6 downto 0):=	"1111001";  
    	constant TWO    :std_logic_vector(6 downto 0):=	"0100100"; 
    	constant THREE  :std_logic_vector(6 downto 0):=	"0110000";	
    	constant FOUR   :std_logic_vector(6 downto 0):=	"0011001";  
    	constant FIVE   :std_logic_vector(6 downto 0):=	"0010010";	
    	constant SIX    :std_logic_vector(6 downto 0):=	"0000010";  
    	constant SEVEN  :std_logic_vector(6 downto 0):=	"1111000";	
   	 constant EIGHT  :std_logic_vector(6 downto 0):="0000000";	
    	constant NINE   :std_logic_vector(6 downto 0):=	"0011000";	
    	constant A      :std_logic_vector(6 downto 0):=	"0001000";	
	constant B      :std_logic_vector(6 downto 0):=	"0000011";	
	constant C      :std_logic_vector(6 downto 0):=	"1000110";	
	constant D      :std_logic_vector(6 downto 0):=	"0100001";	
	constant E      :std_logic_vector(6 downto 0):=	"0000110";	
	constant F      :std_logic_vector(6 downto 0):=	"0000111";		
	constant L	:std_logic_vector(6 downto 0):="1000111";		
	constant U	:std_logic_vector(6 downto 0):="1000001";		
	constant T	:std_logic_vector(6 downto 0):=	"0000111";	
	constant N	:std_logic_vector(6 downto 0):=	"0101011";		
	constant P	:std_logic_vector(6 downto 0):=	"0001100";		
	
-------------------------------------------------------------------------------
    begin
        with bus_vector_1(7 downto 0) select
        HEX_OUT_1 <=		ZERO	        	when	"00000000",
                    		ONE	        	when	"00000001",
                    		TWO	        	when	"00000010",
                   		THREE	        	when	"00000011",
                    		FOUR	        	when	"00000100",
                    		FIVE	        	when	"00000101",
                    		SIX             	when	"00000110",
                    		SEVEN	        	when	"00000111",
                    		EIGHT	        	when	"00001000",
                   		NINE	        	when	"00001001",
                    		A			when	"00001010",
				B			when	"00001011",
				C			when	"00001100",
				D			when	"00001101",
				E			when	"00001110",
				F			when	others;			
       
        with bus_vector_2(7 downto 0) select
        HEX_OUT_2 <=		ZERO	        	when	"00000000",
                    		ONE	            	when	"00000001",
                    		TWO	            	when	"00000010",
                    		THREE	        	when	"00000011",
                    		FOUR	        	when	"00000100",
                    		FIVE	        	when	"00000101",
                    		SIX             	when	"00000110",
                   		SEVEN	        	when	"00000111",
                    		EIGHT	       	 	when	"00001000",
                    		NINE	        	when	"00001001",
                    		A		        when	"00001010",
                    		B		        when	"00001011",
                    		C		        when	"00001100",
                    		D		        when	"00001101",
                    		E		        when	"00001110",
                    		F		        when	others;	
	process (IR_vector)
	begin
	case IR_vector is
			when "0000" => --OUT
					HEX_IR_4	<= N;
					HEX_IR_3	<= ZERO;
					HEX_IR_2 <= P;
					HEX_IR_1 <= "1111111";
			when "0001" => --LOAD
					HEX_IR_4	<= L;
					HEX_IR_3	<= ZERO;
					HEX_IR_2 <= A;
					HEX_IR_1 <= D;
			when "0010" => --ADD
					HEX_IR_4	<= A;
					HEX_IR_3	<= D;
					HEX_IR_2 <= D;
					HEX_IR_1 <= "1111111";
			when "0011" => -- SUB
					HEX_IR_4	<= FIVE;
					HEX_IR_3	<= U;
					HEX_IR_2 <= B;
					HEX_IR_1 <= "1111111";
			when "1110" => --OUT
					HEX_IR_4	<= ZERO;
					HEX_IR_3	<= U;
					HEX_IR_2 <= T;
					HEX_IR_1 <= "1111111";
			when others =>
					HEX_IR_4	<= EIGHT;
					HEX_IR_3	<= EIGHT;
					HEX_IR_2 <= EIGHT;
					HEX_IR_1 <= EIGHT;
			end case;
		end process;
end rtl;
