CPP=g++ 
LEX=flex
YACC=bison -y
SRC=src
BIN=bin
OBJ=obj
MYLIBRARY=$(CURDIR)

all: $(BIN)/parser

$(BIN)/parser: $(OBJ)/parser.tab.c $(OBJ)/lex.yy.c  $(OBJ)/nodes.o $(OBJ)/symbol_table.o $(OBJ)/type_check.o
	@mkdir -p $(BIN)
	$(CPP) -Wno-write-strings $^ -o $@ -I$(OBJ) -I$(SRC)

$(OBJ)/lex.yy.c: $(SRC)/scanner.l 
	@mkdir -p $(OBJ)
	$(LEX) -t  $^ > $@

$(OBJ)/parser.tab.c $(OBJ)/parser.tab.h: $(SRC)/parser.y 
	@mkdir -p $(OBJ)
	$(YACC) -dvt $^ -o $@ 

$(OBJ)/%.o: $(SRC)/%.cpp
	@mkdir -p $(OBJ)
	$(CPP) -c $^ -o $@ -I$(SRC) -I$(OBJ)

clean:
	$(RM) -rf $(OBJ) $(BIN)
	$(RM) output.txt  parser.output graph.gv myAST.dot *.csv
