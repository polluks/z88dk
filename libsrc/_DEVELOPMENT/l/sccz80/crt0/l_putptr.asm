;       Z88 Small C+ Run Time Library 
;       Long functions
;

SECTION seg_code_sccz80

PUBLIC l_putptr

l_putptr:

   ld a,l
   
   ld (bc),a
   inc bc
   
   ld a,h
   
   ld (bc),a
   inc bc
   
   ld a,e
   
   ld (bc),a
   ret
