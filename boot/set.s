.code32
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
    jmp hang

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
    