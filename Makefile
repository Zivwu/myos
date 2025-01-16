# Makefile for building and running a simple OS

# 目标目录
OUT_DIR := out/boot
# 镜像文件
IMG_FILE := out/myos.img
# 引导扇区文件
BOOT_BIN := $(OUT_DIR)/boot.bin
# 源文件
BOOT_SRC := boot/mbr.s

# 创建目标目录
$(OUT_DIR):
	mkdir -p $@

# 编译引导扇区
$(BOOT_BIN): $(BOOT_SRC) | $(OUT_DIR)
	nasm -o $@ $<

# 创建镜像文件
$(IMG_FILE): $(BOOT_BIN)
	@echo "检查镜像文件是否存在..."
	@if [ -e $@ ]; then \
		echo "文件存在"; \
	else \
		echo "文件不存在，创建镜像文件..."; \
		qemu-img create -f raw $@ 60M; \
	fi

# 将引导扇区写入镜像文件
write_boot: $(IMG_FILE)
	dd if=$(BOOT_BIN) of=$< bs=512 count=1 conv=notrunc

# 运行 QEMU
run: write_boot
	qemu-system-i386 -drive format=raw,file=$(IMG_FILE)

# 清理生成的文件
clean:
	rm -rf $(OUT_DIR) $(IMG_FILE)

.PHONY: run clean write_boot
