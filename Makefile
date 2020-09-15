all: parser.tab.o lex.yy.o main.o
	gcc -o etapa2 parser.tab.o lex.yy.o main.o -lfl

main.o: main.c
	gcc -c main.c -Wall

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: scanner.l
	flex scanner.l

parser.tab.o: parser.tab.c
	gcc -c parser.tab.c

parser.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f etapa2 lex.yy.* main.o parser.tab.h parser.tab.c parser.tab.o
