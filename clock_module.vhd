library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock_module is
   generic(cnt_high          : integer:= 20);     )

   port (Clk_50_in         : in  std_logic; 	 
         reset_n           : in  std_logic; 	 
         IN_KEY_n          : in  std_logic; 	
         Use_Manual_Clock  : in  std_logic; 	
         Clk_out           : out std_logic);     
end entity;
		
architecture rtl of clock_module is
signal in_key_n_s1,in_key_n_s2,in_key_n_s3: std_logic;  
signal btn_counter                        : std_logic_vector(cnt_high-1 downto 0); -
signal clk_Status                         : std_logic;
signal start_up                           : std_logic;

begin

   Clk_out <= Clk_50_in when Use_Manual_Clock='0' and start_up='0' else
              clk_status;                               

   process(Clk_50_in,reset_n)
   begin
      if reset_n = '0' then
         btn_counter <= (others => '0');                  
         in_key_n_s1<='0'; 
         in_key_n_s2<='0'; 
         in_key_n_s3<='0'; 
         clk_status<='0';
         start_up<='1';
      elsif rising_edge(Clk_50_in) then                  
         start_up<='0';
         in_key_n_s1<=in_key_n;                           
         in_key_n_s2<=in_key_n_s1;                        
         in_key_n_s3<=in_key_n_s2; 

         btn_counter <= btn_counter + 1;                 
         if in_key_n_s2/=in_key_n_s3 then                 
            btn_counter <= (others => '0');               
         elsif (btn_counter(btn_counter'high) = '1') then 
            clk_Status<= in_key_n_s2;                    
         end if;	   	
      end if;	
   end process;

end architecture;
