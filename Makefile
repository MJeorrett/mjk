CROSS 	?= aarch64-linux-gnu-
CC     	:= $(CROSS)gcc
LD     	:= $(CROSS)ld
OBJCOPY := $(CROSS)objcopy

BUILD := build

CFLAGS := -ffreestanding -nostdlib -fno-builtin -fno-stack-protector \
          -Wall -Wextra -O2 -g \
          -mcpu=cortex-a53 -mgeneral-regs-only \
          -ffunction-sections -fdata-sections

LDFLAGS := -nostdlib -T linker.ld -z max-page-size=4096

OBJS := $(BUILD)/boot.o $(BUILD)/kernel.o

all: $(BUILD)/kernel8.img

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: %.S | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/kernel.elf: $(OBJS) linker.ld | $(BUILD)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(BUILD)/kernel8.img: $(BUILD)/kernel.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD)

run: all
	qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -kernel $(BUILD)/kernel.elf -serial stdio -display none

.PHONY: all clean run
