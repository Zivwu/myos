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
BOOTSEG = 0x7c00

SETUPLEN = 4              #setup.s 占用4个扇区
SETUPSEG = 0x9000         #setup.s 存放位置,并存储

_start:
  movw $BOOTSEG, %ax    ; 假设栈段和代码段相同
  movw %ax, %ss         ; 设置栈段寄存器
  movw $0xFFFE, %sp     ; 设置栈指针
  movw %ax, %cx
  call hello_World


rd_disk_16:
  movw $0x1f7,%dx
  inb %dx,%al             #读取硬盘状态
  testb $0x80 ,%al        #同时检查第 7 位(Busy)和第 3 位(Ready)
  jnz rd_disk_16

  movw $0x1F3,%dx         #LAB
  movb $1,%al
  outb %al,%dx            #设置LBA低地址,1

  movb $0,%al
  movw $0x1f4,%dx
  outb %al,%dx            #设置LBA中地址,0

  movw $0x1f5,%dx
  outb %al,%dx            #设置LBA高地址,0

  # 0-3位，在CHS寻址中表示柱头位，在LBA寻址中，表示LBA地址的24-27位。4位DRV，表示选择主盘或者从盘。
  # 5位、永远为1。6位、如果为0则为CHS寻址，如果为1则为LBA寻址。7位、永远为1。
  # 1110_0000
  movw $0x1f6,%dx         #设置LBA顶地址,并设置硬盘工作模式
  movb $0xe0, %al      
  outb %al,%dx            

  movw $0x1f2,%dx
  movb $SETUPLEN,%al
  outb %al,%dx          # 设置要读取扇区数

  movw $0x1f7, %dx       #
  movb $0x20, %al        # 读扇区指令         
  outb %al, %dx

.wait_disk:
  inb %dx,%al 
  testb $0x8 ,%al
  jnz .wait_disk
  call .go_on_read
  ljmp $0, $SETUPSEG


.go_on_read:
  movw $SETUPSEG,%ax
  movw %ax,%es
  movw $256, %bx
  mulw %bx
  movw %ax, %cx
  movw $0x1f0, %dx
  cld
  movw $0,%di
  call .read
  ret
   

.read:
  inw %dx, %ax 
  stosw
  loop .read
  ret
  

hello_World:
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

