
; void rewind_unlocked_fastcall(FILE *stream)

SECTION code_stdio

PUBLIC _rewind_unlocked_fastcall

_rewind_unlocked_fastcall:
   
   push hl
   ex (sp),ix
   
   call asm_rewind_unlocked
   
   pop ix
   ret
   
   INCLUDE "stdio/z80/asm_rewind_unlocked.asm"
