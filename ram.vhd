library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
entity ram is
    port (
           RAM_CLK          : in std_logic; -- Active on positive edge from key
           addr_in          : in std_logic_vector(3 downto 0);-- address in slide switches
           RO               : in std_logic;
           data_in          : in std_logic_vector(7 downto 0); -- data in slide switches
           we_in            : in std_logic; -- from slide switches
           q_out            : out std_logic_vector(7 downto 0) -- data out to leds
         );
  end entity;

  architecture rtl OF ram is

    --------------RAM-----------------------
  
    TYPE RAM_ARRAY IS ARRAY (0 TO 15) OF --16 byte RAM 16 ROWS OF 8 BIT DATA
            std_logic_vector(7 downto 0);
    SIGNAL RAM_mem: RAM_ARRAY := (
        
        "00011110",    --#0000    LOAD
        "00101111",    --#0001    ADD
        "11100000",    --#0010    OUT

        "00011110",   --#         LOAD
        "00111111",    --#0011    SUB
        "11100000",    

        "00000000",    
        "00000000",    
        "00000000",    

        "00000000",     
        "00000000",    
        "00000000",  
        
        "00000000",    
        "00000000",     
        "00001000",    
        "00000110"   
    );
   ----------------------------------------

   begin

    RAM: PROCESS (RAM_CLK) BEGIN
      
      IF rising_edge(RAM_CLK) then --RO, WE IN? sensitivity list
        
        IF(we_in='1') then
        
           RAM_mem(to_integer(unsigned(addr_in)))<=data_in;
        END IF;
        q_out<= RAM_mem(to_integer(unsigned(addr_in)));
       END IF;
    END PROCESS;
   
    
  
   END architecture rtl;