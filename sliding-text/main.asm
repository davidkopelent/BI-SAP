.cseg

.org 0x1000
.include "printlib.inc"

.org 0
    jmp start

.org 0x100
retez: .db "PRISTI STANICE - HLAVNI NADRAZI", 0
   
start:
    call init_disp
    call setvalues
    ldi r19, 48
   
    print:
        lpm r16, Z+
        call show_char
        inc r17
        cpi r17, 16
        brne noincrement
        add r17, r19
        noincrement: cpi r16, 0
        brne print

    reset:
        call waiting
call check
        call spaces
        call resetstring
        mov r17, r18
        rjmp print

    rjmp start
rjmp PC
   
resetstring:
    ldi r30, low(2*retez)
    ldi r31, high(2*retez)
    ret
   
setvalues:
    call resetstring
    ldi r17, 79
    ldi r18, 79
    ret
   
check:
    cpi r17, 0
    breq resetvalues
    ret
    resetvalues:
        call hardreset
    ret
 
hardreset:
    call setvalues
    ret

spaces:
    mov r17, r18
    ldi r16, ' '
    call show_char
    cpi r18, 64
    brne continue
    call jumponline
    ret
    continue: dec r18
    ret
   
jumponline:
    ldi r17, 15
    cpi r16, 0
    breq change
    change: ldi r18, 15
    ret
   
waiting:  
    ldi r20, 60
    wt: dec r20
    brne wt
    ret