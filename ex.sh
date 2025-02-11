mkdir -p out/boot/

root=$(pwd)
echo "当前目录: $(pwd)"
gcc -m16 -c boot/boot.s  -o out/boot/boot.o
gcc -m16 -c boot/set.s  -o out/boot/set.o


cd out/boot
ld -m elf_i386 -Ttext 0x7c00 -o boot.elf boot.o  set.o
objcopy -O binary boot.elf boot.bin


cd "$root"
name="out/myos.img"
if [ -e $name ]; then
    echo "文件存在"
else
    qemu-img create -f raw out/myos.img 60M
fi
dd if=out/boot/boot.bin of=out/myos.img bs=512 count=10 seek=0 conv=notrunc
# dd if=out/boot/set.bin of=out/myos.img bs=512 count=2 seek=1 conv=notrunc
# qemu-system-i386 -drive format=raw,file=out/myos.img   
qemu-system-i386 -drive format=raw,file=out/myos.img -S -s -monitor stdio
