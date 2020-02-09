;
;	Startup for the Вектор-06Ц (Vector 06c)
;


	module vector06c_crt0


;--------
; Include zcc_opt.def to find out some info
;--------

        defc    crt0 = 1
        INCLUDE "zcc_opt.def"

;--------
; Some scope definitions
;--------

        EXTERN    _main           ;main() is always external to crt0 code
        EXTERN    asm_im1_handler

        PUBLIC    cleanup         ;jp'd to by exit()
        PUBLIC    l_dcal          ;jp(hl)


	defc    TAR__fputc_cons_generic = 1
        defc    TAR__clib_exit_stack_size = 32
        defc    TAR__register_sp = 32768
	defc	CRT_KEY_DEL = 127
	defc	__CPU_CLOCK = 3000000
	defc	CONSOLE_ROWS = 32
	defc	CONSOLE_COLUMNS = 32
        INCLUDE "crt/classic/crt_rules.inc"

        defc CRT_ORG_CODE = 0x0100

	org	  CRT_ORG_CODE

program:
	di
        INCLUDE "crt/classic/crt_init_sp.asm"
        INCLUDE "crt/classic/crt_init_atexit.asm"
	ld	a,195
	ld	($38),a
	ld	hl,asm_im1_handler
	ld	($39),hl
	call    crt0_init_bss
	ld	hl,0
	add	hl,sp
	ld	(exitsp),hl
	xor	a
	out	($10),a

        ld a,$88
        out ($00),a
	ei
	halt

        ld hl,palette+15
        ld de,$100f
INIT1:  ld a,e
        out ($02),a
        ld A,(hl)
        out ($0C),a
        out ($0C),a
        out ($0C),a
        out ($0C),a
        out ($0C),a
        dec hl
        out ($0C),a
        dec e
        out ($0C),a
        dec d
        out ($0C),a
        jp nz,INIT1
; Optional definition for auto MALLOC init
; it assumes we have free space between the end of
; the compiled program and the stack pointer
IF DEFINED_USING_amalloc
    INCLUDE "crt/classic/crt_init_amalloc.asm"
ENDIF
cleanup:
	ld	hl,0
	push	hl
	push	hl
	call	_main
	pop	bc
	pop	bc
	push	hl
	call	crt0_exit
	pop	hl
finished:
	jp	finished
	; Fall into SYSCALL


l_dcal: jp      (hl)            ;Used for function pointer calls

;Colours  00   000   000
;         blue green red
palette:
	defb	@00000000	;Black
	defb	@11000000	;Blue
	defb	@00111000	;Green
	defb	@11111000	;Cyan

	defb	@00000111	;Red
	defb	@11000111	;Magenta
	defb	@00001111	;Brown
	defb	@01011011	;Light grey

	defb	@01001001	;Dark gray
	defb	@11001001	;Light blue
	defb	@01111001	;Light green
	defb	@11111001	;Light cyan

	defb	@01001111	;Light red
	defb	@11001111	;Light magenta
	defb	@01111111	;Yellow
	defb	@11111111	;White

	INCLUDE "crt/classic/crt_runtime_selection.asm" 
	
	INCLUDE	"crt/classic/crt_section.asm"
