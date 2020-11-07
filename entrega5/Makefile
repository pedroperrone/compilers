all: parser.tab.o lex.yy.o tree.o table.o main.o iloc.o
	gcc -o etapa5 parser.tab.o lex.yy.o tree.o table.o main.o iloc.o -lfl

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

tree.o: tree.c
	gcc -c tree.c -Wall

table.o: table.c
	gcc -c table.c -Wall

iloc.o: iloc.c
	gcc -c iloc.c -Wall

clean:
	rm -f etapa5 lex.yy.* main.o parser.tab.h parser.tab.c parser.tab.o tree.o table.o iloc.o parser.output
