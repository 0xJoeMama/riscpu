GHDL=ghdl
GHDLFLAGS=--std=08 -v
AS=riscv64-linux-gnu-as
LD=riscv64-linux-gnu-ld
OBJCOPY=riscv64-linux-gnu-objcopy

ENTITIES=riscvdriver
PROGRAM=simple.elf

.PHONY: all
all: riscvdriver | insns.bin

.PHONY: run
run: all
	$(GHDL) -r  $(GHDLFLAGS) $(ENTITIES) --ieee-asserts=disable-at-0 --backtrace-severity=warning

riscvdriver: types.anal immediate_unit.anal alu.anal branch_controller.anal control_unit.anal mem.anal register_file.anal riscv.anal riscv_driver.anal
	$(GHDL) -e $(GHDLFLAGS) $@

vpath %.vhdl ./src

.PHONY: %.anal
%.anal: %.vhdl
	$(GHDL) -a $(GHDLFLAGS) $^

vpath %.s ./programs/

%.elf: %.o
	$(LD) -T./programs/minimal.ld $^ -o $@

%.o: %.s
	$(AS) $^ -o $@

insns.bin: $(PROGRAM)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf *.o *.elf *.bin
