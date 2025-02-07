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

hang:
    jmp hang
    