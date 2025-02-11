.code16
.section .text
.begin_loader:
    movb $'L', %gs:(0x00)   
    movb $0x0F, %gs:(0x01) 
    movb $'O', %gs:(0x02)  
    movb $0x0F, %gs:(0x03) 
    movb $'A', %gs:(0x04)  
    movb $0x0F, %gs:(0x05) 
    movb $'D', %gs:(0x06)  
    movb $0x0F, %gs:(0x07) 
    movb $'E', %gs:(0x08)  
    movb $0x0F, %gs:(0x09) 
    movb $'R', %gs:(0x0A)  
    movb $0x0F, %gs:(0x0B) 

    # 选择主硬盘
    movw $0x1F6, %dx
    movb $0xA0, %al
    outb %al, %dx

    # 发送 IDENTIFY 命令
    movw $0x1F7, %dx
    movb $0xEC, %al
    outb %al, %dx

# 等待硬盘就绪
.wait:
    inb %dx, %al
    testb $0x80, %al
    jnz .wait
    testb $0x01, %al
    jz .error

    # 读取硬盘信息
    movw $256, %cx
    movw $0x1F0, %dx
    movw $buffer, %di  # 直接将 buffer 的偏移地址赋给 %di

.read:
    inw %dx, %ax
    stosw
    loop .read

    # 处理信息（这里简单打印部分信息）
    movw $buffer, %si  # 直接将 buffer 的偏移地址赋给 %si
    movw $20, %cx
.print:
    lodsw
    call print_hex
    call print_space
    loop .print

    # 无限循环
.hang:
    jmp .hang

.error:
    # 错误处理
    movw $error_msg, %si  # 直接将 error_msg 的偏移地址赋给 %si
    call print_string
    jmp .hang

# 打印十六进制数函数
print_hex:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    movw $4, %cx
.hex_loop:
    rolw $4, %ax
    movb %al, %bl
    andb $0x0F, %bl
    cmpb $10, %bl
    jl .print_digit
    addb $('A' - 10), %bl
    jmp .print_char
.print_digit:
    addb $'0', %bl
.print_char:
    movb $0x0E, %ah
    int $0x10
    loop .hex_loop
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

# 打印空格函数
print_space:
    movb $' ', %al
    movb $0x0E, %ah
    int $0x10
    ret

# 打印字符串函数
print_string:
    lodsb
    orb %al, %al
    jz .end
    movb $0x0E, %ah
    int $0x10
    jmp print_string
.end:
    ret

# 信息存储缓冲区
buffer:
    .space 512

# 错误信息
error_msg:
    .ascii "Error getting disk information!\n"

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

hang:
    jmp hang
    