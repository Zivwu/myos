.code16
.section .text
.global _start 
_start:
  movw %cs, %ax
  movw %ax, %ds
  movw %ax, %ss
  call DispStr
loop1:
  jmp loop1

DispStr:
  movw $msg, %ax
  movw %ax, %bp
  movw $16, %cx
  movw $0x1301, %ax
  movw $0x000c, %bx
  movb $0x00, %dl
  int $0x10
  ret
msg:
  .ascii "Hello, OS world!"
  .org 510
  .word 0xAA55
