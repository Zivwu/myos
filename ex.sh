mkdir -p out/boot/

x86_64-elf-gcc  -c boot/boot.s  -o out/boot/boot.o
x86_64-elf-ld -Ttext=0x7c00 --oformat binary -o out/boot/boot.bin out/boot/boot.o


name="out/myos.img"
if [ -e $name ]; then
    echo "文件存在"
else
    qemu-img create -f raw out/myos.img 60M
fi
dd if=out/boot/boot.bin of=out/myos.img bs=512 count=1 seek=0 conv=notrunc
# dd if=out/boot/loader.bin of=out/myos.img bs=512 count=2 seek=1 conv=notrunc
# qemu-system-i386 -drive format=raw,file=out/myos.img 
qemu-system-i386 -drive format=raw,file=out/myos.img -S -s -monitor stdio
