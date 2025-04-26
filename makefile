cobra: y.tab.c lex.yy.c
	gcc -o cobra y.tab.c lex.yy.c -lfl

y.tab.c: cobra.y
	yacc -d cobra.y

lex.yy.c: cobra.l
	lex cobra.l

clean:
	rm -f cobra y.tab.c lex.yy.c y.tab.h

