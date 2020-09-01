all: main.o lex.yy.o
	gcc -o etapa1 lex.yy.o main.o -lfl

main.o: main.c
	gcc -c main.c main.c -Wall

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm -f etapa1 lex.yy.* main.o
