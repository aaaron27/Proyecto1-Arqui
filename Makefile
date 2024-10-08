all: app

app:
	nasm -f elf64 main.asm -o main.o && ld -o main main.o

clean:
	rm -f main main.o
