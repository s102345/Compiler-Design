HW2: lex.yy.o y.tab.o main.o
	g++ lex.yy.o y.tab.o main.o -o HW2
	@./HW2

main.o: main.cpp main.h
	g++ -c main.cpp

lex.yy.o: lex.yy.c y.tab.h main.h 
	g++ -c lex.yy.c

y.tab.o: y.tab.c main.h 
	g++ -c y.tab.c	

y.tab.c y.tab.h: HW2.y
	yacc -d HW2.y

lex.yy.c: HW2.l 
	flex HW2.l

clean:
	rm -f *.o lex.yy.c y.tab.c