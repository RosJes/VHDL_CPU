library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
--when outputing data on the bus, enable A resp B , write data and AI,BI enable
entity control_unit is
    port(
        Clk, rst_n                  	: in std_logic;
        bus_en_n                    	: out std_logic;   
        data_bus_in                 	: in  std_logic_vector(7 downto 0); 
        Addr_bus                    	: out std_logic_vector(3 downto 0); 
        PC                          	: out std_logic_vector(3 downto 0);
        A_register_out              	: out std_logic_vector(7 downto 0);
        B_register_out              	: out std_logic_vector(7 downto 0);
        ALU_opcode                  	: out std_logic_vector(2 downto 0);
        EO                         	: out std_logic;
        RO                          	: out std_logic;
	HEX_IR_1			: out std_logic_vector (6 downto 0);
	HEX_IR_2			: out std_logic_vector (6 downto 0);
	HEX_IR_3			: out std_logic_vector (6 downto 0);
	HEX_IR_4			: out std_logic_vector (6 downto 0);
        
        HEX_OUT_1                     	: out std_logic_vector (6 downto 0);
        HEX_OUT_2                     	: out std_logic_vector (6 downto 0)
    );
end entity;

architecture rtl of control_unit is
--signals----------------
signal PC_reg       : unsigned(3 downto 0); -- Program pointer, Next instruction to execute
signal IR           : std_logic_vector(7 downto 0); -- Instruction register
signal A_register   : std_logic_vector(7 downto 0);
signal data_bus_out  :std_logic_vector(7 downto 0); --> result from ALU
signal bus_output_2  :std_logic_vector(7 downto 0);

-------------------------
-- Build an enumerated type for the state machine
--Fetch instruction --Decode/Execute
   type state_type is (Fetch_state_1,Fetch_state_2,Fetch_state_3,Decode_state,
   Execute_NOP_state,
   Execute_LDA_state_1,Execute_LDA_state_2,
   Execute_ADD_state_1, Execute_ADD_state_2, Execute_ADD_state_3,
   Execute_SUB_state_1, Execute_SUB_state_2, Execute_SUB_state_3,
   Execute_OUT_state);
-- Register to hold the current state
   signal next_state   : state_type;

   -- Opcodes for the implemented instruction
constant LDA    : std_logic_vector(3 downto 0) := "0001";
constant ADD    : std_logic_vector(3 downto 0) := "0010";
constant UT     : std_logic_vector(3 downto 0) := "1110";
constant SUB    : std_logic_vector(3 downto 0) := "0011";
constant NOP    : std_logic_vector(3 downto 0) := "0000";
component hex_decoder_module 
  port(
        bus_vector_1            	:   in std_logic_vector(7 downto 0);
        bus_vector_2            	:   in std_logic_vector(7 downto 0);
	IR_vector			:   in std_logic_vector(3 downto 0);
		  
	 HEX_IR_1			:   out std_logic_vector (6 downto 0);
	 HEX_IR_2			:   out std_logic_vector (6 downto 0);
	 HEX_IR_3			:   out std_logic_vector (6 downto 0);
	 HEX_IR_4			:   out std_logic_vector (6 downto 0);
        
        HEX_OUT_1                       :   out std_logic_vector (6 downto 0);
        HEX_OUT_2                       :   out std_logic_vector (6 downto 0)
    );
    end component;

   begin
    HEX_UNIT_INSTANCE:  hex_decoder_module  
    port map(
	bus_vector_1 	=> data_bus_out,
	bus_vector_2 	=> bus_output_2,
	IR_vector	=> IR(7 DOWNTO 4),		  

	HEX_IR_1	=>HEX_IR_1,		
	HEX_IR_2	=>HEX_IR_2,				
	HEX_IR_3	=> HEX_IR_3,				
	HEX_IR_4	=> HEX_IR_4,			

	HEX_OUT_1 	=> HEX_OUT_1,
	HEX_OUT_2 	=> HEX_OUT_2
    );

    PC <= std_logic_vector(PC_reg);
    bus_output_2 <=std_logic_vector("0000"& PC_reg(3 downto 0));
    process (rst_n,Clk)
    begin
        if rst_n = '0' then
            PC_reg <= "0000"; -- after reset, PC is zero (i.e address 0)
            IR <= "00000000"; 
            Addr_bus <= "0000" ; 
            next_state <= Fetch_state_1;
            bus_en_n <= '1';
            data_bus_out(7 downto 0) <= "00000000";
            A_register_out <= "00000000";  
            A_register <=    "00000000";       
            B_register_out <= "00000000";            
            EO <= '0';
            RO <= '0';
            
            elsif(rising_edge(Clk)) then
            
                case next_state is
                    when Fetch_state_1 =>
                        EO <= '0';
                        --PC register send value to MAR --> MAR in or send pc register to RAM Addr_out
                        Addr_bus <= std_logic_vector(PC_reg);
                        RO <= '1';
                        next_state <= Fetch_state_2; 
                    
                    when Fetch_state_2 =>
                        RO <= '1';
                        next_state <= Fetch_state_3; 
                    
                    when Fetch_state_3 =>
                        --RAM data --> IR register, IR enable (IR picks up data from BUS)
                        IR <= data_bus_in;
                        next_state <= Decode_state; 
                    ---------- Decode state
                    when Decode_state =>  -- Decode and execute instruction state
                    PC_reg <= PC_reg + 1;
                    case IR(7 DOWNTO 4) is
                        when NOP =>                                   -- 0, NOP
                        next_state <= Execute_NOP_state;
                        when LDA =>
                        Addr_bus <= std_logic_vector(IR(3 DOWNTO 0));  
                            next_state <= Execute_LDA_state_1;
                        when ADD =>
                        Addr_bus <= std_logic_vector(IR(3 DOWNTO 0));  
                            next_state <= Execute_ADD_state_1;
                        when SUB =>
                        Addr_bus <= std_logic_vector(IR(3 DOWNTO 0));  
                            next_state <= Execute_SUB_state_1;
                        when UT =>
                            next_state <= Execute_OUT_state;
                        when others => 
                            next_state <= Fetch_state_1;
                    end case;
                    ---------execution NOP_state
                    when Execute_NOP_state =>  -- Decode and execute instruction state
                        data_bus_out <= (others => '0');
                        next_state <= Fetch_state_1;
                    ---------- execution LDA_state
                    when Execute_LDA_state_1 =>  
                        RO <= '1';
                        EO <= '0';
                        next_state <= Execute_LDA_state_2;
                    ------------------------------
                    --execution LDA_2 state
                    when Execute_LDA_state_2 =>  
                        A_register_out <= data_bus_in;
                        next_state <= Fetch_state_1;
                    -------------------------
                    ---------- execution ADD_state
                    when Execute_ADD_state_1 =>  
                        ALU_opcode <= "000";
                        RO <= '1';
                        next_state <= Execute_ADD_state_2;
                    ---------- execution ADD_state
                    when Execute_ADD_state_2 =>  
                        B_register_out <= data_bus_in;
                        RO <= '0';
                        EO <= '1';
                        next_state <= Execute_ADD_state_3;
                    ------------------------------
                    when Execute_ADD_state_3 =>  
                        A_register <= data_bus_in;
                        EO <= '1';
                        next_state <= Fetch_state_1;
                    ----execution SUB state-----
                    when Execute_SUB_state_1 =>  
                        ALU_opcode <= "001";
                        RO <= '1';
                        next_state <= Execute_SUB_state_2;
                    ---------------------------------
                    when Execute_SUB_state_2 =>  
                        B_register_out <= data_bus_in;
                        RO <= '0';
                        EO <= '1';
                        next_state <= Execute_SUB_state_3;
                    ------------------------------------
                    when Execute_SUB_state_3 =>  
                        A_register <= data_bus_in;
                        EO <= '1';
                        next_state <= Fetch_state_1;
                    ---------- execution OUT_state
                    when Execute_OUT_state =>  
                        data_bus_out <= A_register;-- take result from ALU
                        EO <= '0';
                        next_state <= Fetch_state_1;
                    ------------------------------
                end case;
        end if;
    end process;
end rtl;
