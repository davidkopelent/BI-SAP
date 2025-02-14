.dseg          
.org 0x100      

flag: .byte 1      

.cseg  

.org 0x1000
.include "printlib.inc"

.org 0
    jmp start
   
.org 0x16          
    jmp interrupt
   
.org 0x100
win: .db "WINNER",0
los: .db "LOSER",0
strt: .db "START",0
 
start:
    call init_disp
    call init_button
    call init_int

    ldi r19, 0    
    sts flag, r19
   
menu:
    call clear_screen
    ldi r18, '0'
    ldi r20, '0'
    ldi r21, '0'
    ldi r22, '0'
   
    ldi r30, low(2*strt)
    ldi r31, high(2*strt)
   
    ldi r17, 2
    print_start:
lpm r16, Z+
cpi r16, 0
breq initial_pause
call show_char
inc r17
jmp print_start

initial_pause:
    call long_loop
    call long_loop
   
initial:
    call start_conversion
    cpi r30, 0b10010000
    breq clean
    jmp initial
   
clean:
    call clear_screen
   
pause:
    call long_loop
   
controller1:  
    call start_conversion  
    cpi r30, 0b10010000
    breq pause2
   
    lds r19, flag
    cpi r19, 0      
    breq controller1  
                   
    ldi r19, 0      
    sts flag, r19
 
    inc r20
    mov r16, r20
    ldi r17, 2
    call show_char

    inc r21
    mov r16, r21
    ldi r17, 3
    call show_char
   
    inc r22
    mov r16, r22
    ldi r17, 4
    call show_char
       
    cpi r20, '9'
    brne controller1
    ldi r20, '0'
    ldi r21, '0'
    ldi r22, '0'    
    jmp controller1
   
pause2:
    mov r25, r20
    call long_loop
   
controller2:  
    call start_conversion  
    cpi r30, 0b10010000
    breq pause3
   
    lds r19, flag
    cpi r19, 0      
    breq controller2
                   
    ldi r19, 0      
    sts flag, r19
   
    cpi r21, '9'
    breq refresh

    inc r21
    mov r16, r21
    ldi r17, 3
    call show_char

    inc r22
    mov r16, r22
    ldi r17, 4
    call show_char

    cpi r21, '9'
    brne controller2
   
refresh:
    ldi r21, '0'
    ldi r22, '0'
    jmp controller2
   
pause3:
    mov r26, r21
    call long_loop
   
controller3:
    call start_conversion  
    cpi r30, 0b10010000
    breq result
   
    lds r19, flag
    cpi r19, 0      
    breq controller3
                   
    ldi r19, 0      
    sts flag, r19
   
    cpi r21, '9'
    breq refresh2

    inc r22
    mov r16, r22
    ldi r17, 4
    call show_char
   
    cpi r22, '9'
    brne controller3

refresh2:
    ldi r22, '0'
    jmp controller3
       
result:
    call long_loop
    call long_loop
    mov r27, r22
    call clear_screen    
    ldi r22, 3
    cp r25, r26
    brne loserjmp
    cp r25, r27
    brne loserjmp
    cp r25, r27
    breq winner
    loserjmp: jmp loser
       
init_button:
    push r16
    lds r16, ADCSRA
    ori r16, (1<<ADEN)
    sts ADCSRA, r16    
    ldi r16, (0b01<<REFS0) | (1<<ADLAR)
    sts ADMUX, r16
    pop r16
    ret
 
start_conversion:  
    lds r16, ADCSRA
    ori r16, (1<<ADSC)
    sts ADCSRA, r16
   
    wait: lds r16, ADCSRA
    sbrc r16, ADSC
    rjmp wait
   
    lds r30, ADCH
    andi r30, 0b11110000
    ret
   
clear_screen:
    ldi r17, 0
    clearloop:
ldi r16, ' '
call show_char
inc r17
cpi r17, 10
brne clearloop
    ret
   
winner:
    ldi r30, low(2*win)
    ldi r31, high(2*win)    
    ldi r17, 2
   
    print_winner:
lpm r16, Z+
cpi r16, 0
breq decrement
call show_char
inc r17
jmp print_winner

    decrement: dec r22
    breq end

    call long_loop
    call long_loop
    call clear_screen
    call long_loop
    call long_loop
    jmp winner

loser:
    ldi r30, low(2*los)
    ldi r31, high(2*los)    
    ldi r17, 2
   
    print_loser:
lpm r16, Z+
cpi r16, 0
breq decrement2
call show_char
inc r17
jmp print_loser

    decrement2: dec r22
    breq end

    call long_loop
    call long_loop
    call clear_screen
    call long_loop
    call long_loop
    jmp loser
   
end:
    call start_conversion  
    cpi r30, 0b10010000
    brne repeat
    jmp menu
    repeat: jmp end
   
init_int:          
    push r19
    cli

    clr r19
    sts TCNT1H, r19
    sts TCNT1L, r19

    ldi r19, (1<<OCIE1A)
    sts TIMSK1, r19

    ldi r19, (1<<WGM12) | (0b101<<CS10)
    sts TCCR1B, r19

    ldi r19, 20
    sts OCR1AH, r19
    ldi r19, 8
    sts OCR1AL, r19

    clr r19
    out EIMSK, r19
   
    sei
    pop r19
    ret

interrupt:        
    push r19
    in r19, SREG
    push r19

    ldi r19, 1
    sts flag, r19

    pop r19
    out SREG, r19
    pop r19
    reti
   
long_loop:
    ldi r28, 30
    counter:
call loop2
dec r28
brne counter
    ret

loop:
    ldi r23, 33
    cek:
    ldi r24, 120
    cek2:
dec r24
brne cek2
    dec r23
    brne cek
    ret
   
loop2:
    ldi r23, 254
    cek3:
    ldi r24, 254
    cek4:
dec r24
brne cek4
    dec r23
    brne cek3
    ret