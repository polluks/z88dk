
; unsigned long ftell_fastcall(FILE *stream)

INCLUDE "clib_cfg.asm"

SECTION code_stdio

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF __CLIB_OPT_MULTITHREAD & $02
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _ftell_fastcall

_ftell_fastcall:
   
   push hl
   pop ix
   
   INCLUDE "stdio/z80/asm_ftell.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _ftell_fastcall

EXTERN _ftell_unlocked_fastcall

defc _ftell_fastcall = _ftell_unlocked_fastcall
   
INCLUDE "stdio/z80/asm_ftell.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
