library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock_module is
   generic(cnt_high          : integer:= 20);     -- Avg??r hur m??nga klockpulser som knappen har p?? sig att bli stabil (20 bitar ger 10.48ms vid 50MHz )

   port (Clk_50_in         : in  std_logic; 	 -- Denna m??ste alltid vara kopplad mot kristallen p?? DE1-SoC kortet (50MHz).
         reset_n           : in  std_logic; 	 -- Reset signal, aktivt l??g
         IN_KEY_n          : in  std_logic; 	 -- Detta ??r den manuella klockan, kopplad till tryckknappen KEY0 p?? DE1-SoC kortet.
         Use_Manual_Clock  : in  std_logic; 	 -- N??r denna ??r '1' s?? kommer IN_KEY_n att l??ggas ut p?? Clk_out ist??llet f??r Clk_50_in.
         Clk_out           : out std_logic);      -- Utg??ende klockan, som ska anv??ndas i resten av systemet.
end entity;
		
architecture rtl of clock_module is
signal in_key_n_s1,in_key_n_s2,in_key_n_s3: std_logic;  
signal btn_counter                        : std_logic_vector(cnt_high-1 downto 0); -- Pulsr??knare
signal clk_Status                         : std_logic;
signal start_up                           : std_logic;

begin

   Clk_out <= Clk_50_in when Use_Manual_Clock='0' and start_up='0' else
              clk_status;                                 -- L??gg ut v??r klockstatus p?? Clk_out

   process(Clk_50_in,reset_n)
   begin
      if reset_n = '0' then
         btn_counter <= (others => '0');                  -- Alla positioner ??r satta till 0 vid reset
         in_key_n_s1<='0'; 
         in_key_n_s2<='0'; 
         in_key_n_s3<='0'; 
         clk_status<='0';
         start_up<='1';
      elsif rising_edge(Clk_50_in) then                   -- Har vi positiv flank p?? 50MHz klockan
         start_up<='0';
         in_key_n_s1<=in_key_n;                           -- Synka, ta bort metastabilitet
         in_key_n_s2<=in_key_n_s1;                        -- Synka, ta bort metastabilitet
         in_key_n_s3<=in_key_n_s2; 

         btn_counter <= btn_counter + 1;                  -- R??kna upp med 1 tills vi kommer till v??rdet 524288 (0x80000) (en klockpuls ??r 20ns vid 50MHz)
         if in_key_n_s2/=in_key_n_s3 then                 -- Ska vi anv??nda knappen?
            btn_counter <= (others => '0');               -- Nollst?ll counter
         elsif (btn_counter(btn_counter'high) = '1') then -- Om den sista biten i v??r vektor har blivit 1 s?? kommer vi hit och anser att knappen varit stabil under s?? m??nga klockpulser som vi angett p?? cnt_high
            clk_Status<= in_key_n_s2;                     -- Skriv knappens status till Clk_Status
         end if;	   	
      end if;	
   end process;

end architecture;