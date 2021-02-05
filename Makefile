CPP=g++
LEX=flex
YACC=bison -y
SRC=src
BIN=bin
MYLIBRARY=$(CURDIR)

all: $(BIN)/mycompiler

$(BIN)/mycompiler: lex.yy.c parser.tab.c
	@mkdir -p $(BIN)
	$(CPP) -Wno-write-strings lex.yy.c parser.tab.c -o $(BIN)/mycompiler

lex.yy.c: $(SRC)/scanner.l parser.tab.h
	$(LEX) -t $^ > $@

parser.tab.c parser.tab.h: $(SRC)/parser.y 
	$(YACC) -dvt $^ -o $@

clean:
	$(RM) lex.yy.c parser.tab.c parser.tab.h $(BIN)/mycompiler parser.output

