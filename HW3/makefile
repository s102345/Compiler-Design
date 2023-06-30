HW3: lex.yy.o y.tab.o main.o HW3.o
	g++ lex.yy.o y.tab.o main.o HW3.o -o HW3
	@./HW3

HW3.o: HW3.cpp HW3.h 
	g++ -c HW3.cpp

main.o: main.cpp main.h
	g++ -c main.cpp

lex.yy.o: lex.yy.c y.tab.h main.h 
	g++ -c lex.yy.c

y.tab.o: y.tab.c main.h 
	g++ -c y.tab.c	

y.tab.c y.tab.h: HW3.y
	yacc -d HW3.y

lex.yy.c: HW3.l 
	flex HW3.l

clean:
	rm -f *.o lex.yy.c y.tab.c
