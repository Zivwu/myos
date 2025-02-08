.code16

# BIOS 
# 此模块会被BIOS 加载存放到 [BOOTSTART]处,模块大小为512K,最后32位为0xAA55,是引导扇区的结束标志
# 运行在16位实模式下



.globl begtext, begdata, begbss, endtext, enddata, endbss,_start
.text
begtext:
.data
begdata:
.bss
begbss:
.text


# 
BOOTSEG = 0X7C00


_start:
  call .hello_World
  jmp .loop


#使用BIOS提供的0x10中断显示字符串
.hello_World:
  movw $msg, %ax
  movw %ax, %bp
  movw $16, %cx
  movw $0x1301, %ax
  movw $0x000c, %bx
  movb $0x00, %dl
  int $0x10
  ret

.loop:
  jmp .loop


msg:
  .ascii "Hello, OS world!"
  .org 510
  .word 0xAA55
.text
endtext:
.data
enddata:
.bss
endbss:

