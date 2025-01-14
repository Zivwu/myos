; os/src/boot/mbr.s
; 设置开始的地址，并且初始化寄存器
SECTION MBR vstart=0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00

; 利用0x06号功能实现清理屏幕
; AL = 0x06 功能号
; AL 上卷的行数(如果为0,表示全部)
; BH 上卷行属性
; (CL,CH) = 窗口左上角的(X,Y)位置,这里是 (0,0)
; (DL,DH) = 窗口右下角的(X,Y)位置,这里是 (80,25)
    mov    ah, 0x06
    mov    al, 0x00
    mov    bh, 0x7
    mov    bl, 0x00
    mov    cx, 0
    mov    dx, 0x184f
    int    0x10            ; int 0x10

; 获取光标位置
; AL = 0x03 功能号
; bh 寄存器存储的是待获取光标的页号
    mov    ah, 3
    mov    bh, 0
    int    0x10

; 打印字符串
; BP 字符串地址,BP需要通过AX访问，不能直接给BP内存数据
; AL = 0x13 功能号
; AL = 0x01 显示字符串,光标跟随移动
; CX = 0x03 字符串长度
; BH = 0x00 要显示的页号
; BL = 0x02 字符属性,属性黑底绿字
    mov ax, message
    mov bp, ax
    mov ax, 0x1301
    mov cx, 0x03
    mov bx, 0x02
    int 0x10

; 循环等待
    jmp $
; 要显示的字符串
    message db "MBR"
; 将510个字节中剩余的空间填充为0
; $ 是当前地址
; $$ 是本节开头地址，也就是0x7c00
    times 510-($-$$) db 0
    db 0x55,0xaa
