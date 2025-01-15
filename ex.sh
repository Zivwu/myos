mkdir -p out/boot/

nasm -o  out/boot/boot.bin boot/mbr.s 

name="out/myos.img"
if [ -e $name ]; then
    echo "文件存在"
else
    qemu-img create -f raw out/myos.img 60M
fi
dd if=out/boot/boot.bin of=out/myos.img bs=512 count=1 conv=notrunc
qemu-system-i386 -drive format=raw,file=out/myos.img

# if [ -e fileimgPath ]; then
#     echo "文件存在"
# else
#     echo "文件不存在"
# fi

# qemu-img create -f raw out/myos.img 60M
# nasm -o  out/boot/boot.bin boot/mbr.s 
# dd 