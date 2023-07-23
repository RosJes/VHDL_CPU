library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
entity CPU is
    port(
	Clk,rst_n                   				:in std_logic;
	Key                         				:in std_logic_vector(0 downto 0);
	HEX_IR_1						:out std_logic_vector (6 downto 0);
	HEX_IR_2						:out std_logic_vector (6 downto 0);
	HEX_IR_3						:out std_logic_vector (6 downto 0);
	HEX_IR_4						:out std_logic_vector (6 downto 0);
	HEX0                        				:out std_logic_vector(6 DOWNTO 0);
	HEX1                        				:out std_logic_vector(6 DOWNTO 0)
    );
end entity CPU;

architecture rtl of CPU is
--signals-----
signal bus_en_n, EO, zero,RO        				:   std_logic;
signal Addr_bus                     				:   std_logic_vector(3 DOWNTO 0);
signal PC                           				:   std_logic_vector(3 DOWNTO 0);
signal data_bus_in                  				:   std_logic_vector(7 DOWNTO 0);
signal A_register_s                 				:   std_logic_vector(7  DOWNTO 0);
signal B_register_s                 				:   std_logic_vector(7  DOWNTO 0);
signal ALU_opcode_s                 				:   std_logic_vector(2 downto 0);
signal ALU_result_s                 				:   std_logic_vector(7 downto 0);
signal q_out_s                      				:   std_logic_vector(7 downto 0);
signal reset_nt1,reset_nt2          				:   std_logic; 
signal Man_clk_n                    				:   std_logic;
signal clk_out                      				:   std_logic;
--------------
---COMPONENTS-------------------------------------------------------------------
    --RAM
    component ram 
    port (
           RAM_CLK                  : in std_logic; 
           RO                       : in std_logic;
           addr_in                  : in std_logic_vector(3 downto 0);
           data_in                  : in std_logic_vector(7 downto 0);
           we_in                    : in std_logic; 
           q_out                    : out std_logic_vector(7 downto 0) 
         );
    end component;
    --CONTROL UNIT
    component control_unit
      port(
        Clk, rst_n                  : in std_logic;
        bus_en_n                    : out std_logic;   
        data_bus_in                 : in  std_logic_vector(7 downto 0); 
        Addr_bus                    : out std_logic_vector(3 downto 0); 
        PC                          : out std_logic_vector(3 downto 0);
        A_register_out              : out std_logic_vector(7 downto 0);
        B_register_out              : out std_logic_vector(7 downto 0);
        ALU_opcode                  : out std_logic_vector(2 downto 0);
        EO                          : out std_logic;
        RO                          : out std_logic;
  	HEX_IR_1		    : out std_logic_vector (6 downto 0);
  	HEX_IR_2		    : out std_logic_vector (6 downto 0);
  	HEX_IR_3		    : out std_logic_vector (6 downto 0);
  	HEX_IR_4		    : out std_logic_vector (6 downto 0);
        
        HEX_OUT_1                   : out std_logic_vector (6 downto 0);
        HEX_OUT_2                   : out std_logic_vector (6 downto 0)
    );
    end component;
    ---ALU-----------------------
    component ALU_module 
        port(
        Clk                         : in std_logic;
         Reset_n                    : in std_logic;
         a,b                        : in std_logic_vector(7 downto 0); 
         alu_control                : in std_logic_vector(2 downto 0); 
         alu_result                 : out std_logic_vector(7 downto 0) ; -- ALU Output Result
         zero                       : out std_logic ;-- Zero Flag
         EO                         : in std_logic
         );
    end component;
component clock_module
GENERIC (cnt_high : INTEGER
         );
   port(
     Clk_50_in                      : in std_logic;
     reset_n                        : in std_logic;
     IN_KEY_n                       : in std_logic;
     Use_Manual_Clock               : in std_logic;
     Clk_out                        : out std_logic
     );
end component;

    ----------------------------------------------------------------
    begin
        process(Clk,rst_n)                 				-- Synk av reset med 2 vippor
        begin
           if (rst_n ='0')then
              reset_nt1<='0';
              reset_nt2 <='0';
           elsif rising_edge(Clk) then
                     reset_nt1<='1';
              reset_nt2 <= reset_nt1;
           end if;
        end process;
          
       Man_clk_n <= '1';
       
        
CLOCK_MODULE_INSTANCE : clock_module
       generic map(cnt_high => 19
                )
       port map(
         Clk_50_in => Clk,
         reset_n => reset_nt2,
         IN_KEY_n => Key(0),
         Use_Manual_Clock => Man_clk_n,
         Clk_out => clk_out
         );
RAM_INSTANCE: ram 
                port map(
                        RAM_CLK         =>       clk_out,--Clk, 
                        RO              =>       RO,      
                        addr_in         =>       Addr_bus,      
                        data_in         =>       "00000000",--give constants     
                        we_in           =>       '0',   --give constants    
                        q_out           =>       q_out_s    --RAM IN RAM OUT? SIGNAL TO ENABLE RAM ON BUS   
                );
CONTROL_UNIT_INSTANCE: control_unit
                port map (
                        Clk             	=>      clk_out,--Clk, 
                        rst_n           	=>      reset_nt2,              
                        bus_en_n        	=>      bus_en_n ,               
                        data_bus_in     	=>      data_bus_in  ,                 
                        Addr_bus        	=>      Addr_bus  ,             
                        PC              	=>      PC   ,
                        A_register_out  	=>      A_register_s,          
                        B_register_out  	=>      B_register_s,     
                        ALU_opcode      	=>      ALU_opcode_s,                
                        EO              	=>      EO,   
                        RO              	=>      RO,   
			HEX_IR_1				=> 	HEX_IR_1	,				
			HEX_IR_2				=> 	HEX_IR_2,			
			HEX_IR_3				=> 	HEX_IR_3,				
			HEX_IR_4				=> 	HEX_IR_4,			
                        HEX_OUT_1         =>      HEX0 ,  
                        HEX_OUT_2         =>      HEX1   
                );
ALU_UNIT_INSTANCE: alu_module
                    port map(
                        Clk             =>      clk_out,--Clk, 
                        Reset_n         =>      reset_nt2, 
                        a               =>      A_register_s,
                        b               =>      B_register_s,
                        alu_control     =>      ALU_opcode_s,
                        alu_result      =>      ALU_result_s ,
                        zero            =>      zero,
                        EO              =>      EO
                    );

data_bus_in <= q_out_s when RO='1'else ALU_result_s when EO ='1'else "00000000";
end rtl;
