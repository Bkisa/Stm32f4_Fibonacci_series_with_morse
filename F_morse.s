/*
  * authors : Buğrahan KISA
  * Date    : 8:03:2019
  * Project : Fabonacci series blinking with morse alphabet
*/

.thumb
.syntax unified

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Definitions
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Definitions section. Define all the registers and
@ constants here for code readability.

@ Constants
.equ     bin,    1000
.equ     yuz,     100

.equ     delay1sec,      400000
.equ     delay3sec,       1200000
@ Register Addresses
@ You can find the base addresses for all the peripherals from Memory Map section
@ RM0090 on page 64. Then the offsets can be found on their relevant sections.

@ RCC   base address is 0x40023800
@   AHB1ENR register offset is 0x30
.equ     RCC_AHB1ENR,   0x40023830      @ RCC AHB1 peripheral clock register (page 180)

@ GPIOD base address is 0x40020C00
@   MODER register offset is 0x00
@   ODR   register offset is 0x14
.equ     GPIOD_MODER,   0x40020C00      @ GPIOD port mode register (page 281)
.equ     GPIOD_ODR,     0x40020C14      @ GPIOD port output data register (page 283)

@ GPIOA base address is 0x40020000
@   MODER register offset is 0x00
@   IDR   register offset is 0x10
 .equ     GPIOA_MODER,   0x40020000      @ GPIOA port mode register (buton için)
 .equ     GPIOA_IDR,     0x40020010        @ GPIOA port output data register (buton için)

@ Start of text section
.section .text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Vectors
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Vector table start
@ Add all other processor specific exceptions/interrupts in order here
    .long    __StackTop                 @ Top of the stack. from linker script
    .long    _start +1                  @ reset location, +1 for thumb mode

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Main code starts from here
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

_start:
    @ Enable GPIOD Peripheral Clock (bit 3 in AHB1ENR register)
    ldr r6, = RCC_AHB1ENR               @ Load peripheral clock register address to r6
    ldr r5, [r6]                        @ Read its content to r5
    orr r5, 0x00000009                  @ Set bit 3 to enable GPIOD clock
    str r5, [r6]                        @ Store back the result in peripheral clock register

    @ Make GPIOD Pin12 as output pin (bits 25:24 in MODER register)
    ldr r6, = GPIOD_MODER               @ Load GPIOD MODER register address to r6
    ldr r5, [r6]                        @ Read its content to r5
    and r5, 0x55FFFFFF                  @ Clear bits 24, 25 for P12
    orr r5, 0x55000000                  @ Write 01 to bits 24, 25 for P12
    str r5, [r6]                        @ Store back the result in GPIOD MODER register
    @ Make GPIOA PinA0 as output 
    ldr r6, = GPIOA_MODER                  
    ldr r5, [r6]
    and r5, 0xFFFFFF00                 @ PinA0 defined as input
    str r5,[r6]

    movs r1,0  @
    movs r7,0  @ -> these register is used to calculate fabonacci series
    movs r9,1  @
_id:
    ldr r6, =GPIOD_ODR  
    ldr r5, [r6]
    orr r5, 0x8000       @show group_id : 0b1000 = 8  
    str r5, [r6]

btn_cntrl:   @ control pressing buton
    
    ldr r6, =GPIOA_IDR
    ldr r5,[r6]
    and r5, #0x0001      @if button is pressed,
    cmp r5, #0x0001      @ relating bit is changed form 0 to 1 by buton   
    beq process_begin    @then start process for fabonacci   
    b btn_cntrl          @ if it isn't pressed , control it again.




process_begin:
    ldr r6, =GPIOA_IDR
    ldr r5,[r6]

    ldr r6, =GPIOD_ODR  
    ldr r5, [r6]
    orr r5, 0x0000       @Leds are off
    str r5, [r6]
   
 f_start:
    
    
        
  cmp r1,20             @ We finish this series at 20 , for this, control it
  beq son
    
    adds r4,r7,r9       @ We send r4 register's value as series input value
    movs r7,r9          @ 
    movs r9,r4          @ -> we interchange values to calculate series for next input value
    
    bl I_O              @ after these operation , go to dividing operation
   
    adds r1,1           @ to finish series at 20

    b _id               @ after blinking series , show again group_id      

delay1:
    subs r0, 1
    cmp r0, 0     
    bne delay1
    bx lr



MORSE:
    movs r8,5     
    
    cmp r2,5     
    bgt f_start2 @if bigger then 5, goto f_start2 to blink leds
    
    
    f_start1:  @ part of blinking led just a sec if r2 is equal or less than 5
     cmp r2,0     
     beq  f_start3 @ if r2 is equal 0, r2 is sent f_start3
     orr r5, 0xF000
     str r5, [r6]
     push {lr}
     ldr r0, =delay1sec
     bl delay1
     pop {lr}
     and r5, 0x0000
     str r5, [r6]
     subs r2,1
     subs r8 ,1
     push {lr}
     ldr r0, =delay1sec
     bl delay1
     pop {lr}
     b f_start1

     f_start3:@ part of blinking led 3 secs if r2 is equal or less than 5
     cmp r8,0
     beq f_start4
     orr r5, 0xF000
     str r5, [r6]
     ldr r0, =delay3sec
     push {lr}
     bl delay1
     pop {lr}
     subs r2,1
     subs r8,1
     and r5, 0x0000
     str r5, [r6]
     ldr r0, =delay1sec
     push {lr}
     bl delay1
     pop {lr}
     b f_start3



     f_start4:  
       ldr r0, =delay3sec
       push {lr}
       bl delay1
       pop {lr}
       bx lr

   f_start2:  @ part of blinking led 3 sec if r2 is equal or bigger than 5
     subs r2, 5   
     f_start2a:
     cmp r2, 0     
     beq  f_start3a
     orr r5, 0xF000
     str r5, [r6]
     push {lr}
     ldr r0, =delay3sec
     bl delay1
     pop {lr}
     and r5, 0x0000
     str r5, [r6]
     subs r2,1
     subs r8 ,1
     push {lr}
     ldr r0, =delay1sec
     bl delay1
     pop {lr}
     b f_start2a

     f_start3a:
     cmp r8,0
     beq f_start4a
     orr r5, 0xF000
     str r5, [r6]
     ldr r0, =delay1sec
     push {lr}
     bl delay1
     pop {lr}
     subs r2,1
     subs r8,1
     and r5, 0x0000
     str r5, [r6]
     ldr r0, =delay1sec
     push {lr}
     bl delay1
     pop {lr}
     b f_start3a



     f_start4a:
       ldr r0, =delay3sec
       push {lr}
       bl delay1
       pop {lr}
       bx lr



I_O:
   /*
    * Part of diving 1000,100,10 and 1 to get digits
    * dividing number , how much digits it has.
    * then we send that valuse to morse
    * and to calculate again next digit, multipicaiton and subtraction related value
   */
   ldr r3,=#1000
   cmp r4 , r3
   blt f_start_I_O_1
   udiv r2,r4,r3
   
   push {lr}
   bl MORSE
   pop {lr}
   udiv r2,r4,r3  
      
   muls r2,r2,r3
   subs r4,r2
   b I_O

 f_start_I_O_1:
   ldr r3,=#100
   cmp r4 , r3
   blt f_start_I_O_2
   udiv r2,r4,r3   
   push {lr}
   bl MORSE
   pop {lr}
   udiv r2,r4,r3   
   muls r2,r2,r3
   subs r4,r2
   b f_start_I_O_1

f_start_I_O_2:
   ldr r3,=#10
   cmp r4 , r3
   blt f_start_I_O_3
   udiv r2,r4,r3   
   push {lr}
   bl MORSE
   pop {lr}
   udiv r2,r4,r3   
   muls r2,r2,r3
   subs r4,r2
   b f_start_I_O_2

f_start_I_O_3:
   mov r2,r4
      
   push {lr}
   bl MORSE
   pop {lr}
   
   
   bx lr
/*
 * After r1 reaches 20 ,goto start, reset all of them
*/
son:
       b _start
