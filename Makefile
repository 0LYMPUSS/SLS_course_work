ASM                     = nasm
ASMFLAGS        = -felf64 -g -Isrc/


# This feature allows you to call functions from libc and other shared libraries.
# You get support for native calls by address and dlsym.
LINKER          = ld
LINKERFLAGS =
LIBS        =


all: bin/forthress

bin/forthress: build/forthress.o build/lib.o
	mkdir -p bin
	$(LINKER) -o bin/forthress  $(LINKERFLAGS) -o bin/forthress build/forthress.o build/lib.o $(LIBS)

build/forthress.o: src/forthress.asm src/macro_lib.inc src/words.inc src/lib.inc
	mkdir -p build
	$(ASM) $(ASMFLAGS) src/forthress.asm -o build/forthress.o

build/lib.o: src/lib.inc src/lib.asm
	mkdir -p build
	$(ASM) $(ASMFLAGS) src/lib.asm -o build/lib.o

