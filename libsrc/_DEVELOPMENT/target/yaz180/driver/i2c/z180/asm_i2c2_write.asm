;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; https://github.com/feilipu/
;
; https://feilipu.me/
;
;
; This work was authored in Marrakech, Morocco during May/June 2017.

    INCLUDE "config_private.inc"

    SECTION code_driver

    PUBLIC asm_i2c2_write

    EXTERN __i2c2TxPtr
    EXTERN __i2c2ControlEcho, __i2c2ControlInput, __i2c2SlaveAddr, __i2c2SentenceLgth

;   Write to the I2C Interface, using Byte Mode transmission
;   void i2c_write( char addr, char *dp, char length, char mode );
;   parameters passed in registers
;   HL = pointer to data to transmit, uint8_t *dp
;   D  = 7 bit address of slave device, uint8_t _i2c2SlaveAddr
;   C  = length of data sentence, uint8_t _i2c2SentenceLgth
;   B  = mode with buffer/byte [1|0] and boolean stop at conclusion [0x10|0x00], uint8_t _i2c2ControlInput

.asm_i2c2_write
    ld a,(__i2c2ControlEcho)
    tst __IO_I2C_CON_ECHO_BUS_RESTART|__IO_I2C_CON_ECHO_BUS_ILLEGAL
    ret NZ                      ;just exit if a fault

    and __IO_I2C_CON_ECHO_BUS_STOPPED
    jr Z,asm_i2c2_write         ;if the bus is not stopped, then wait till it is

    ld a,c
    cp 67                       ;check the sentence for over length
    ret NC

    or a                        ;check the sentence provided for zero length, clear carry
    ret Z                       ;return if the sentence is 0 length

    ld (__i2c2SentenceLgth),a   ;store the sentence length

    ld a,d                      ;store the 7 bit slave address
    rla                         ;ensure we're writing Bit 0:[W=0]
    ld (__i2c2SlaveAddr),a

    ld (__i2c2TxPtr),hl         ;store the buffer pointer

    ld a,b                      ;store the mode and stop booleans
    ld (__i2c2ControlInput),a

    and a,__IO_I2C_CON_MODE     ;check whether buffer or byte mode is required
    or a,__IO_I2C_CON_ENSIO|__IO_I2C_CON_STA
    ld (__i2c2ControlEcho),a    ;store enabled, start flag, and mode in the control echo
    ld bc,__IO_I2C2_PORT_BASE|__IO_I2C_PORT_CON

    di
    in0 a,(ITC)                 ;get INT/TRAP Control Register (ITC)
    or ITC_ITE2                 ;mask in INT2
    out0 (ITC),a                ;enable external interrupt

    ld a,(__i2c2ControlEcho)
    out (c),a                   ;then set the interface enable, STA bit, and mode bit
    ei
    ret

