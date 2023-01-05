# file:         wdASM.Makefile for wdASM assembly routines collection
# content:      make rules to build wdASM library
# author:       Stefan Wittwer, info@wittwer-datatools.ch


# define directory path variables
#PROJECTS = ..
#ASM      = $(PROJECTS)/wdASM
BIN      = $(HOME)/.local/bin
LIB      = $(HOME)/.local/lib


# define modules
WDASM     = wdASM
WDASM_MOD = sadd32fp256 \
            sadd64fp256 \
            smul32fp256 \
            smul64fp256 \
            ssub32fp256 \
            ssub64fp256 \
            vadd32fp256 \
            vadd64fp256 \
            vdiv32fp256 \
            vdiv64fp256 \
            vmul32fp256 \
            vmul64fp256 \
            vspr32fp256 \
            vspr64fp256 \
            vsub32fp256 \
            vsub64fp256


# define build parameters for debug and release version
ASMD = -F dwarf -f elf64 -g -O0 -Wall
ASMR = -f elf64 -Ox
DMDD = -cov -de -debug -g -m64 -map -v -w -L-verbose
DMDR = -boundscheck=off -inline -m64 -O -release


# define sources, objects and targets
WDASM_D       = $(addsuffix .d, $(WDASM))
WDASM_O       = $(addsuffix .o, $(WDASM))
WDASM_DBG_O   = $(addsuffix .dbg.o, $(WDASM))
WDASM_OBJ     = $(addsuffix .o, $(WDASM_MOD))
WDASM_DBG_OBJ = $(addsuffix .dbg.o, $(WDASM_MOD))
WDASM_LIB     = $(addprefix $(LIB)/, $(addsuffix .a, $(WDASM)))
WDASM_DBG_LIB = $(addprefix $(LIB)/, $(addsuffix .dbg.a, $(WDASM)))
WDASM_EXE     = $(addprefix $(BIN)/, $(WDASM))
WDASM_DBG_EXE = $(addprefix $(BIN)/, $(WDASM).dbg)


# build main executable for testing purpose
$(WDASM_EXE) : $(WDASM_O) $(WDASM_LIB)
	dmd $(DMDR) -of=$(WDASM_EXE) $(WDASM_O) $(WDASM_LIB)
	dmd $(DMDD) -of=$(WDASM_DBG_EXE) $(WDASM_DBG_O) $(WDASM_DBG_LIB)
	rm $(WDASM_O) $(WDASM_DBG_O)

$(WDASM_O) : $(WDASM_D)
	dmd -c $(DMDR) -of=$(WDASM_O) $(WDASM_D)
	dmd -c $(DMDD) -of=$(WDASM_DBG_O) $(WDASM_D)


# build library
$(WDASM_LIB) : $(WDASM_OBJ)
	dmd -lib $(DMDR) -of=$(WDASM_LIB) $(WDASM_OBJ)
	dmd -lib $(DMDD) -of=$(WDASM_DBG_LIB) $(WDASM_DBG_OBJ)
	rm $(WDASM_OBJ)
	rm $(WDASM_DBG_OBJ)

sadd32fp256.o : sadd32fp256.asm
	nasm $(ASMD) -l sadd32fp256.lst -o sadd32fp256.dbg.o sadd32fp256.asm
	nasm $(ASMR) -o sadd32fp256.o sadd32fp256.asm

sadd64fp256.o : sadd64fp256.asm
	nasm $(ASMD) -l sadd64fp256.lst -o sadd64fp256.dbg.o sadd64fp256.asm
	nasm $(ASMR) -o sadd64fp256.o sadd64fp256.asm

smul32fp256.o : smul32fp256.asm
	nasm $(ASMD) -l smul32fp256.lst -o smul32fp256.dbg.o smul32fp256.asm
	nasm $(ASMR) -o smul32fp256.o smul32fp256.asm

smul64fp256.o : smul64fp256.asm
	nasm $(ASMD) -l smul64fp256.lst -o smul64fp256.dbg.o smul64fp256.asm
	nasm $(ASMR) -o smul64fp256.o smul64fp256.asm

ssub32fp256.o : ssub32fp256.asm
	nasm $(ASMD) -l ssub32fp256.lst -o ssub32fp256.dbg.o ssub32fp256.asm
	nasm $(ASMR) -o ssub32fp256.o ssub32fp256.asm

ssub64fp256.o : ssub64fp256.asm
	nasm $(ASMD) -l ssub64fp256.lst -o ssub64fp256.dbg.o ssub64fp256.asm
	nasm $(ASMR) -o ssub64fp256.o ssub64fp256.asm

vadd32fp256.o : vadd32fp256.asm
	nasm $(ASMD) -l vadd32fp256.lst -o vadd32fp256.dbg.o vadd32fp256.asm
	nasm $(ASMR) -o vadd32fp256.o vadd32fp256.asm

vadd64fp256.o : vadd64fp256.asm
	nasm $(ASMD) -l vadd64fp256.lst -o vadd64fp256.dbg.o vadd64fp256.asm
	nasm $(ASMR) -o vadd64fp256.o vadd64fp256.asm

vdiv32fp256.o : vdiv32fp256.asm
	nasm $(ASMD) -l vdiv32fp256.lst -o vdiv32fp256.dbg.o vdiv32fp256.asm
	nasm $(ASMR) -o vdiv32fp256.o vdiv32fp256.asm

vdiv64fp256.o : vdiv64fp256.asm
	nasm $(ASMD) -l vdiv64fp256.lst -o vdiv64fp256.dbg.o vdiv64fp256.asm
	nasm $(ASMR) -o vdiv64fp256.o vdiv64fp256.asm

vmul32fp256.o : vmul32fp256.asm
	nasm $(ASMD) -l vmul32fp256.lst -o vmul32fp256.dbg.o vmul32fp256.asm
	nasm $(ASMR) -o vmul32fp256.o vmul32fp256.asm

vmul64fp256.o : vmul64fp256.asm
	nasm $(ASMD) -l vmul64fp256.lst -o vmul64fp256.dbg.o vmul64fp256.asm
	nasm $(ASMR) -o vmul64fp256.o vmul64fp256.asm

vspr32fp256.o : vspr32fp256.asm
	nasm $(ASMD) -l vspr32fp256.lst -o vspr32fp256.dbg.o vspr32fp256.asm
	nasm $(ASMR) -o vspr32fp256.o vspr32fp256.asm

vspr64fp256.o : vspr64fp256.asm
	nasm $(ASMD) -l vspr64fp256.lst -o vspr64fp256.dbg.o vspr64fp256.asm
	nasm $(ASMR) -o vspr64fp256.o vspr64fp256.asm

vsub32fp256.o : vsub32fp256.asm
	nasm $(ASMD) -l vsub32fp256.lst -o vsub32fp256.dbg.o vsub32fp256.asm
	nasm $(ASMR) -o vsub32fp256.o vsub32fp256.asm

vsub64fp256.o : vsub64fp256.asm
	nasm $(ASMD) -l vsub64fp256.lst -o vsub64fp256.dbg.o vsub64fp256.asm
	nasm $(ASMR) -o vsub64fp256.o vsub64fp256.asm


# phoney targets
clean : 
	rm -f $(WDASM_LIB)
	rm -f $(WDASM_DBG_LIB)
	rm -f $(WDASM_EXE)
	rm -f $(WDASM_DBG_EXE)

debug :
	gdb -x wdASM.dbg

run :
	$(BIN)/$(WDASM_EXE)



# end of Makefile
