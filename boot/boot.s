.code16
.section .text
.global _start 
_start:
  movw %cs, %ax
  movw %ax, %ds
  movw %ax, %ss

  
  movw $0x01, %ax 
  movw $0x600, %bx      
  movw $1, %cx                    
  call rd_disk_m_16
  call seta20.1
  call DispStr
  movw $0xb800, %ax 
  movw %ax, %gs 
  ljmp $0x0, $0x600

seta20.1:
  inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
  testb $0x2, %al
  jnz seta20.1

  movb $0xd1, %al                                 # 0xd1 -> port 0x64
  outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
  inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
  testb $0x2, %al
  jnz seta20.2

  movb $0xdf, %al                                 # 0xdf -> port 0x60
  outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
  ret
  
rd_disk_m_16:
    # eax=LBA扇区号
    # ebx=Loader内存
    # ecx=扇区数量
    movl %eax, %esi        # 备份eax
    movw %cx, %di          # 备份cx

    movw $0x1f2, %dx       # 设置要写入端口，即读取端口数
    movb %cl, %al          # 设置要读取扇区数

    outb %al, %dx          # 设置 out 用于将al数据发送到指定的输出dx端口
    movl %esi, %eax        # 恢复eax

    movw $0x1f3, %dx       # 设置要写入端口，即LBA低地址        
    outb %al, %dx          

    movb $8, %cl           # ax右移八位   
    shrw %cl, %ax          # 一个寄存器或内存中的值进行逻辑右移操作cl位
    movw $0x1f4, %dx       # 设置要写入端口，即LBA中地址 
    outb %al, %dx

    shrw %cl, %ax          # ax右移八位   
    movw $0x1f5, %dx       # 设置要写入端口，即LBA高地址 
    outb %al, %dx

    shrw %cl, %ax          # ax右移八位
    andb $0x0f, %al        # 保留低4位，设置高4位为 0000
    orb $0xe0, %al         # 保留低4位，设置高4位为 1110
    movw $0x1f6, %dx
    outb %al, %dx

    movw $0x1f7, %dx       #
    movb $0x20, %al        # 读扇区指令         
    outb %al, %dx

.not_ready:                # 未准备好
    nop                    # 不执行任何指令，占用一个机器周期
    inb %dx, %al           # 查看读取状态
    andb $0x88, %al        # 与 10001000 做与运算
    cmpb $0x08, %al        # 比较第三位和第七位
    jnz .not_ready

    movw %di, %ax          # 要读的扇区数
    movw $256, %dx         # 乘以256，即要读多少次
    mulw %dx               # 修改为 mulw 进行16位乘法
    movw %ax, %cx          # 将要读的次数传给cx
    movw $0x1f0, %dx       # 要读的端口号

.go_on_read:
    inw %dx, %ax           # 从输入端口 dx 中读取数据到 al 寄存器
    movw %ax, (%bx)        # 将ax中数据给bx地址的内存
    addw $2, %bx           # bx中内存地址加2
    loop .go_on_read       # 循环cx次
    ret


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
