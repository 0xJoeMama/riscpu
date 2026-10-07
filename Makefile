GHDL=ghdl
GHDLFLAGS=--std=08
AS=riscv64-elf-as
ASFLAGS=-march=rv32i
LD=riscv64-elf-ld
LDFLAGS=-b elf32-littleriscv
OBJCOPY=riscv64-elf-objcopy

PROGRAM=simple.elf
SRC=src/bitsize.sv src/constants.sv src/regs/register_file.sv src/mem/ram.sv src/mem/rom.sv src/riscv.sv
SYNTH=riscv.ys

.PHONY: all
all: riscv_rtl.svg riscv_synth.svg register_file.svg memory.svg rom.svg

mod.v: insns.txt

%.svg: %.json
	netlistsvg $^ -o $@

%.json: mod.v
	yosys $*.ys

mod.v: $(SRC)
	sv2v $(SRC) > mod.v

vpath %.s ./programs/

%.elf: %.o
	$(LD) $(LDFLAGS) -T./programs/minimal.ld $^ -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $^ -o $@

insns.bin: $(PROGRAM)
	$(OBJCOPY) -O binary $< $@

insns.txt: insns.bin
	hexdump -v -e '/1 "%02x\n"' $^ > $@

clean:
	rm -rf  *.elf *.bin *.v *.svg *.json
