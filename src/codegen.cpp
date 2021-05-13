#include "codegen.h"

int argcount;
int datanum;
string r1, r2, r3;
int regcount = 1;
map <string, vector<string>> code; 
vector<string> data_segment; 
queue <pair<string, sEntry*>>  used_reg;
queue <pair<string, sEntry*>>  free_reg;
map <string, string> reg;

string curr_func;
ofstream asm_file;

void putln(string a){
  code[curr_func].push_back(a);
}

void putdata(string a){
  data_segment.push_back(a);
}

void print_code(){
  asm_file.open("code.asm");
  for(int m=0;m<data_segment.size();m++){
    asm_file << data_segment[m]<<endl;
  }
  asm_file<<endl;
  asm_file<<".text"<<endl;
  asm_file << "main:" << endl;
  for(int i = 0; i<code["main"].size(); ++i){
    asm_file << '\t' << code["main"][i]<< endl;
  }
  asm_file << endl;
  map<string , std::vector<string>>::iterator it;
  it = code.find("main");
  code.erase(it);
  for(auto it = code.begin(); it!=code.end(); ++it){
    asm_file << it->first << ":" << endl;
    for(int i = 0; i<code[it->first].size(); ++i){
      asm_file << '\t' << code[it->first][i]<< endl;
    }
    asm_file << endl;
  }
}


void code_generator() {
  datanum = 0;
  putdata(".data");
  putdata("reservedspace: .space 1024");
  putdata("stringspace: .space 1024");
  putdata("_newline: .asciiz \"\\n\"");
  curr_func = "main";
  putln("");
  int goto_jump = 0;//0 impilies jumping to labelled statement on goto else execute next statement
  for (int i = 0; i < IRcode.size(); ++i) {
    putln("# " + to_string(i + 1) + " : " + IRcode[i].res.first + " = " + IRcode[i].id1.first + " " + IRcode[i].op.first + " " +IRcode[i].id2.first);
    if(IRcode[i].op.first=="GOTO") goto_jump = 0;
    if (Goto_labels.find(i) != Goto_labels.end()) {
      save_reg();
      putln(Goto_labels[i] + ":");
      if(goto_jump == 1) goto_jump = 0;
    }
    if(goto_jump) continue;
    if (IRcode[i].stmtCounter == -2) {
      argcount = 0;
      curr_func = IRcode[i].op.first;
      curr_func.erase(curr_func.begin(), curr_func.begin() + 5);
      curr_func.erase(curr_func.end() - 7, curr_func.end());
      if (curr_func == "main") {

        // set the frame pointer of the callee
        putln("sub $sp, $sp, 200");
        putln("la $fp, ($sp)");
        int size = symbol_table::lookup("main")->size;
        // update the stack pointer to allocate space for the registers  
        putln("sub $sp, $sp, " + to_string(size));
      } else {
    
        int size = symbol_table::lookup(curr_func)->size + 4;//eax storage

        
        putln("sub $sp, $sp, 72");//18 main register
        call_seq_asm_code();
        // create space for local data
        putln("li $v0, " + to_string(size));
        putln("sub $sp, $sp, $v0");// update the stack pointer to allocate space for the registers 

        
        string param_list = symbol_table::funcArgList(curr_func);
        int param_num = 0;
        int param_size = 76;
        string temp = param_list;
        if (param_list != "") {
          string delim = string(",");
          string temp1;
          int f1 = temp.find_first_of(delim);
          while (f1 != -1) {
            temp1 = temp.substr(0, f1);
            temp = temp.substr(f1 + 1);
            f1 = temp.find_first_of(delim);
            if(param_num<4){
              putln("li $s6, " + to_string(param_size));
              putln("sub $s7, $fp, $s6");
              putln("sw $a" + to_string(param_num) + ", 0($s7)");
            }
            char a[50];
            strcpy(a, temp1.c_str());
            param_size += symbol_table::getSize(a);
            param_num++;
          }
          if(param_num<4){
            putln("li $s6, " + to_string(param_size));
            putln("sub $s7, $fp, $s6");
            putln("sw $a" + to_string(param_num) + ", 0($s7)");
          }
        }
      }
    } else if (IRcode[i].stmtCounter == -4) { // this stmtCounter is specially set
                                               // for param with constant string
      putdata("DataString" + to_string(datanum) + ": .asciiz " +
              IRcode[i].id1.first);
      putln("la $a" + to_string(argcount) + ", DataString" +
              to_string(datanum));
      argcount++;
      datanum++;
    }

    else if (IRcode[i].stmtCounter == -1) {
      // for parameters of the functional call

      if (IRcode[i].op.first == "param") {
        if (IRcode[i].id1.second != NULL) {
          if (IRcode[i].id1.second->is_init == -5) {//postfix_expression '[' expression ']'	
            putln("li $s6, "+to_string(IRcode[i].id1.second->size) );
            putln("sub $s7, $fp, $s6");
            putln("lw $t8, 0($s7)");
            putln("li $t9, 4");
            putln("mult $t8, $t9");
            putln("mflo $t9");
            putln("li $s6, " +to_string(IRcode[i].id1.second->offset)); // put the offset in s6
            putln("add $s6, $s6, $t9");
            putln("sub $s7, $fp, $s6"); // combine the two components of the
                                          // address
            putln("lw $t6, 0($s7)");
            r1 = "$t6";
          }
          else r1 = get_reg(IRcode[i].id1);
          if(argcount < 4){
            putln("move $a" + to_string(argcount) + ", " + r1);
          }
          else{
            int param_num = 0;
            int param_size = 76;
            char *a = "int";//32 bit isliye
            param_size += argcount* symbol_table::getSize(a);

            putln("li $s6, " + to_string(param_size));
            putln("sub $s7, $sp, $s6");
            putln("sw "+r1+", 0($s7)");
          }
          argcount++;
        } else {// symbol table entry not find
          if(argcount < 4){
            putln("addi $a" + to_string(argcount) + ",$0, " +
                    IRcode[i].id1.first);
          }
          else{
            int param_num = 0;
            int param_size = 76;
            char *a = "int";
            param_size += argcount* symbol_table::getSize(a);
            putln("addi $t9, $0, " +   IRcode[i].id1.first);
            putln("li $s6, " + to_string(param_size));
            putln("sub $s7, $sp, $s6");
            putln("sw $t9, 0($s7)");
        }
          argcount++;
        }
      }

      // -------------------for assignment operators-------------------
      else if (IRcode[i].op.first == "=" || IRcode[i].op.first == "realtoint" || IRcode[i].op.first == "inttoreal") {
        if (IRcode[i].res.second == NULL)
        if (IRcode[i].res.second->is_init == -5)//postfix_expression '[' expression ']'
          r3 = string("$t7");
        else
          r3 = get_reg(IRcode[i].res);

        if (IRcode[i].id1.second != NULL) {
          if (IRcode[i].id1.second->is_init == -5) {
            array_to_reg(IRcode[i].id1, string("$t6"));
            r2 = string("$t6");
          }
          else r2 = get_reg(IRcode[i].id1);
          putln("move " + r3 + ", " + r2);
        }
        else {//constant
          putln("addi " + r3 + ", $0, " + IRcode[i].id1.first);
        }

        if (IRcode[i].res.second->is_init == -5) {//t7, t9
         if(curr_func == "main"){
          putln("li $s6, "+to_string(IRcode[i].res.second->size) );
          putln("sub $s7, $fp, $s6");
          putln("lw $t8, 0($s7)");
          putln("li $t9, 4");
          putln("mult $t8, $t9");
          putln("mflo $t9");
          putln("li $s6, " + to_string(IRcode[i].res.second->offset)); // put the offset in s6
          putln("add $s6, $s6, $t9");
          putln("sub $s7, $fp, $s6"); // combine the two components of the address
         }
         else{
           putln("li $s6, "+to_string(IRcode[i].res.second->size) );
           putln("addi $s6, 76");
           putln("sub $s7, $fp, $s6");
           putln("lw $t8, 0($s7)");
           putln("li $t6, 4");
           putln("mult $t8, $t6");
           putln("mflo $t6");
           putln("li $s6, "+ to_string(IRcode[i].res.second->offset));
           putln("addi $s6, 76");
           putln("sub $s7, $fp, $s6");
           putln("lw $t8, 0($s7)");
           putln("sub $s7, $t8, $t6");
         }
          putln("sw $t7, 0($s7)");
        }
      }

      // ------------------- unary operators-------------------
      else if (IRcode[i].op.first == "&") {
        r1 = get_reg(IRcode[i].res);
        int off = IRcode[i].id1.second->offset;
        off = -off;
        string u = to_string(off);
        putln("add " + r1 + ", $fp, " + u);
        if(IRcode[i].id1.second->is_init == -5){
           putln("li $s6, "+to_string(IRcode[i].id1.second->size) );
           putln("sub $s7, $fp, $s6");
           putln("lw $t8, 0($s7)");
           putln("li $t7, 4");
           putln("mult $t8, $t7");
           putln("mflo $t7");
           putln("addi $t7, "+to_string(off));
           putln("neg $t7, $t7");
           u = string("$t7");//use of u
           putln("add "+r1+", $fp, $t7");
        }
        save_reg();
      }

      else if (IRcode[i].op.first == "unary*") {
        r1 = get_reg(IRcode[i].res);
        if(IRcode[i].id1.second->is_init == -5) r2 = string("$t6");
        else r2 = get_reg(IRcode[i].id1);
        if (IRcode[i].id1.second != NULL) {
          if (IRcode[i].id1.second->is_init == -5) {
            putln("li $s6, "+to_string(IRcode[i].id1.second->size) );
            putln("sub $s7, $fp, $s6");
            putln("lw $t8, 0($s7)");
            putln("li $t9, 4");
            putln("mult $t8, $t9");
            putln("mflo $t9");
            putln("li $s6, " + to_string(IRcode[i].id1.second->offset)); // put the offset in s6
            putln("add $s6, $s6, $t9");
            putln("sub $s7, $fp, $s6"); // combine the two components of the
                                          // address
            putln("lw $t6, 0($s7)");
          }
        }
        putln("lw " + r1 + ", 0(" + r2 + ")");
        save_reg();
      }

      else if (IRcode[i].op.first == "unary-") {
        r1 = get_reg(IRcode[i].res);
        if (IRcode[i].id1.second != NULL) {
          if(IRcode[i].id1.second->is_init == -5 ) r2 = string("$t6");
          else r2 = get_reg(IRcode[i].id1);
          if (IRcode[i].id1.second != NULL) {
            if (IRcode[i].id1.second->is_init == -5) {
              array_to_reg(IRcode[i].id1, r2);
            }
          }
          putln("neg " + r1 + ", " + r2);
        } else
          putln("addi " + r1 + ", $0, -" + IRcode[i].id1.first);
      }

      else if (IRcode[i].op.first == "~" || IRcode[i].op.first == "!") {
        r1 = get_reg(IRcode[i].res);
        r2 = get_reg(IRcode[i].id1);
        putln("not " + r1 + ", " + r2);
      }

      else if (IRcode[i].op.first == "unary+") {
        r1 = get_reg(IRcode[i].res);
        if(IRcode[i].id1.second->is_init == -5) r2 = string("$t6");
        else r2 = get_reg(IRcode[i].id1);
        if (IRcode[i].id1.second != NULL) {
          if (IRcode[i].id1.second->is_init == -5) {
            array_to_reg(IRcode[i].id1, r2);
          }
        }
        putln("lw " + r1 + ", " + r2);
      }

      //      ------------------- addition of int ------------------- 
      else if (IRcode[i].op.first == "+int") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("add " + r1 + ", " + r2 + ", " + r3);
        } 
        else putln("addi " + r1 + ", " + r2 + ", " + IRcode[i].id2.first);
      }

      
      // -------------------substraction of integer-------------------
      else if (IRcode[i].op.first == "-int") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("sub " + r1 + ", " + r2 + ", " + r3);
        } 
        else putln("addi " + r1 + ", " + r2 + ", -" +
                  IRcode[i].id2.first);
      }

      // -------------------multiplication of integer-------------------
      else if (IRcode[i].op.first == "*int") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("mult " + r2 + ", " + r3);
          putln("mflo " + r1);
        } else {
          putln("addi $t9, $0, " + IRcode[i].id2.first);
          putln("mult " + r2 + ", $t9");
          putln("mflo " + r1);
        }
      }
      // -------------------division of integers-------------------
      else if (IRcode[i].op.first == "/int") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("div " + r2 + ", " + r3);
          putln("mflo " + r1);
        } else {
          putln("addi $t9, $0, " + IRcode[i].id2.first);
          putln("div " + r2 + ", $t9");
          putln("mflo " + r1);
        }
      }
      //      ------------------- addition of real/float ------------------- 
      else if (IRcode[i].op.first == "+real") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("mtc1 "+ r2 +", $f0");
          putln("mtc1 "+ r3 +", $f1");
          putln("add.s $f2, $f0, $f1");
          putln("mfc1 $f2, " + r1);
        } 
        else{
          putln("mtc1 "+ r2 +", $f0");
          putln("li.s $f1, "+ IRcode[i].id2.first);
          putln("add.s $f2, $f0, $f1");
          putln("mfc1 $f2, " + r1);
        }
      }
      //      ------------------- subtraction of real/float------------------- 
      else if (IRcode[i].op.first == "-real") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("mtc1 "+ r2 +", $f0");
          putln("mtc1 "+ r3 +", $f1");
          putln("sub.s $f2, $f0, $f1");
          putln("mfc1 $f2, " + r1);
        } 
        else{
          putln("mtc1 "+ r2 +", $f0");
          putln("li.s $f1, -" + IRcode[i].id2.first);
          putln("add.s $f2, $f0, $f1");
          putln("mfc1 $f2, " + r1);
        }
      }

      //      ------------------- multiplication of real/float ------------------- 
      else if (IRcode[i].op.first == "*real") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("mtc1 "+ r2 +", $f0");
          putln("mtc1 "+ r3 +", $f1");
          putln("mul.s " + r1 + ", " + r2 + ", " + r3);
          putln("mfc1 $f2, " + r1);
        } else {
          putln("mtc1 "+ r2 +", $f0");
          putln("add.s $f0, $0, " + IRcode[i].id2.first);
          putln("mul.s " + r1 + ", " + r2 + ", $f0");
          putln("mfc1 $f2, " + r1);
        }
      }

      //      ------------------- division of real/float------------------- 
      else if (IRcode[i].op.first == "/real") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("mtc1 "+ r2 +", $f0");
          putln("mtc1 "+ r3 +", $f1");
          putln("div.s " + r1 + ", " + r2 + ", " + r3);
          putln("mfc1 $f2, " + r1);
        } else {
          putln("mtc1 "+ r2 +", $f0");
          putln("add.s $f0, $0, " + IRcode[i].id2.first);
          putln("div.s " + r1 + ", " + r2 + ", $f0");
          putln("mfc1 $f2, " + r1);
        }
      }

      // ------------------- modulo of integers------------------- 
      else if (IRcode[i].op.first == "%") {
        operator_asm1(i);
        if (IRcode[i].id2.second != NULL) {
          operator_asm2(i);
          putln("div " + r2 + ", " + r3);
          putln("mfhi " + r1);
        } else {
          putln("addi " + r1 + ", $0, " + IRcode[i].id2.first);
          putln("div " + r2 + ", " + r1);
          putln("mfhi " + r1);
        }
      }

      // ------------------- printing float------------------- 
      else if (IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "printf") {
        print_float_asm();
      }

      // ------------------- printing  integer ------------------- 
      else if (IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "printn") {
        print_int_asm();
      }
      // ------------------- printing string------------------- 
      else if (IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "prints") {
        print_string_asm();
      }
      // ------------------- reading from file------------------- 
      else if( IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "fread"){
        read_file();
      }
      // ------------------- writing to file------------------- 
      else if( IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "fwrite"){
        // string is already in a0
        write_file();
      }
      // ------------------- length of string------------------- 
      else if( IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "strlen"){
        // string is already in a0
        putln("la $a0, stringspace");
        putln("li $a1, 1024");
        putln("li $t0, 0");
        putln("loop:");
        putln("lb $t1, 0($a0)");
        putln("beqz $t1, exit");
        putln("addi $a0, $a0, 1");
        putln("addi $t0, $t0, 1");
        putln("j loop");
        putln("exit:");
        putln("mov $v0, $t0");
        putln("jr $ra");
        argcount = 0;
      }
      // ------------------- math power function------------------- 
      else if( IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "pow"){
        // $a0 = x, $a1 = n, power x^n
        putln("jal Power");
        putln("move $s0,$v0");//storing the return value
        putln("Power:");
        putln("sub $sp, $sp, -4");  // make room for the call-frame
        putln("sw $ra, 4($sp)");  // save $ra on stack
        putln("if: ");   
        putln("bne $a1, $0, else_if");   
        putln("li $v0, 1");   // # $v0 contains result
        putln("j end_if");   
        putln("else_if:");   
        putln("bne $a1, 1, else");   
        putln("move $v0, $a0");   
        putln("j end_if");   
        putln("else: ");   
        putln("addi $a1, $a1, -1 ");   
        putln("jal Power ");   
        putln("mul $v0, $v0, $a0");   
        putln("end_if:");   
        putln("lw $ra, 4($sp)");   
        putln("addi $sp, $sp, 4");   
        putln("jr $ra");   // restore return addr. to $ra
        
        argcount = 0;
      }
      // ------------------- math sqrt function-------------------
      else if( IRcode[i].op.first == "CALL" && IRcode[i].id1.first == "sqrt"){
        //$a0 contains n
        putln("jal isqrt");
        putln("move $s0,$v0");//storing the return value
        putln("isqrt: ");
        putln("li	$v0, 0");
        putln("li	$s0, 1");
        putln("sll	$s0, $s0, 30");
        putln("move	$s1, $a0");
        putln("bgt	$s0, $s1, loop");
        putln("shift:");
        putln("srl	$s0, $s0, 2");
        putln("bgt	$s0, $s1, shift");
        putln("loop: ");
        putln("add	$s2, $s0, $v0");
        putln("blt	$s1, $s2, shiftright");
        putln("sub	$s1, $s1, $s2");
        putln("srl	$v0, $v0, 1");
        putln("add	$v0, $v0, $s0");
        putln("b	continue");
        putln("shiftright: ");
        putln("srl	$v0, $v0, 1");
        putln("continue: ");
        putln("srl	$s0, $s0, 2");
        putln("bne	$s0, 0, loop");
        putln("done: ");
        putln("jr	$ra");
      }

      // ------------------- for '<'------------------- 
      else if (IRcode[i].op.first == "<") {
        assignment_exp_asm(i);
        putln("slt " + r3 + ", " + r2 + ", " + r1);
      }
      // ------------------- for '>'------------------- 
      else if (IRcode[i].op.first == ">") {
        assignment_exp_asm(i);
        putln("sgt " + r3 + ", " + r2 + ", " + r1);
      }

      // ------------------- for '>='------------------- 
      else if (IRcode[i].op.first == "GE_OP") {
        assignment_exp_asm(i);
        putln("sge " + r3 + ", " + r2 + ", " + r1);
      }

      // ------------------- for '<='------------------- 
      else if (IRcode[i].op.first == "LE_OP") {
        assignment_exp_asm(i);
        putln("sle " + r3 + ", " + r2 + ", " + r1);
      }

      // ------------------- for 'EQ_OP' i.e. '=='------------------- 
      else if (IRcode[i].op.first == "EQ_OP") {
        assignment_exp_asm(i);
        putln("seq " + r3 + ", " + r2 + ", " + r1);
      }

      // ------------------- for 'NE_OP' ( '!=' )------------------- 
      else if (IRcode[i].op.first == "NE_OP") {
        assignment_exp_asm(i);
        putln("sne " + r3 + ", " + r2 + ", " + r1);
      }
      // -------------------return 0-------------------
      else if (IRcode[i].op.first == "RETURN" && curr_func == "main") {
        putln("li $a0, 0");
        putln("li $v0, 10");
        putln("syscall");
      }
      // ------------------- reading float-------------------
      else if (IRcode[i].op.first == "CALL" &&
                 IRcode[i].id1.first == "scanf") {
        r1 = get_reg(IRcode[i].res);
        scan_float_asm();
      }
      // ------------------- reading int-------------------
      else if (IRcode[i].op.first == "CALL" &&
                 IRcode[i].id1.first == "scann") {
        r1 = get_reg(IRcode[i].res);
        scan_int_asm();
      }
      // ------------------- reading string-------------------
      else if (IRcode[i].op.first == "CALL" &&
                 IRcode[i].id1.first == "scans") {
        r1 = get_reg(IRcode[i].res);
        scan_string_asm();
      }
      // ------------------- return from function other than main-------------------
      else if (IRcode[i].op.first == "RETURN" &&
                 curr_func != "main") {
        if (IRcode[i].id1.second != NULL) {
          r1 = get_reg(IRcode[i].id1);
          putln("move $v0, " + r1);
        } else {
          putln("li $v0, " + IRcode[i].id1.first);
        }
        putln("b " + curr_func + "end");
      } else if (IRcode[i].op.first == "CALL") {
        putln("jal " + IRcode[i].id1.first);
        if (IRcode[i].res.second != NULL) {
          r1 = get_reg(IRcode[i].res);
          putln("move " + r1 + ", $v0");
          argcount = 0;
        }
      }

    }
    //   return sequence
    else if (IRcode[i].stmtCounter == -3 && curr_func != "main") {
      putln(curr_func + "end:");
      int sizeEnd = symbol_table::lookup(curr_func)->size + 4;
      putln("addi $sp, $sp, " + to_string(sizeEnd));
      return_seq_asm_code();
      putln("addi $sp, $sp, 72");
      putln("jr $ra");
    }
    // ------------------- condtional and unconditional goto-------------------
    else {
      if (IRcode[i].op.first == "GOTO" && IRcode[i].id1.first == "") {
        goto_jump = 1;
        save_reg();
        putln("j " + Goto_labels[IRcode[i].stmtCounter]);
      } else if (IRcode[i].op.first == "GOTO" &&
                 IRcode[i].id1.first == "IF") {
        save_reg();
        if (IRcode[i].id2.second != NULL) {
          r1 = get_reg(IRcode[i].id2);
          putln("bne $0, " + r1 + ", " +Goto_labels[IRcode[i].stmtCounter]);
        } else {
          putln("addi $t9, $0, " + IRcode[i].id2.first);
          putln("bne $0, $t9, " + Goto_labels[IRcode[i].stmtCounter]);
        }
      }
    }
    save_reg();
  }
}


void reset_reg(){
  pair<string, sEntry*> t0 = pair<string, sEntry*>("$t0", NULL);
  pair<string, sEntry*> t1 = pair<string, sEntry*>("$t1", NULL);
  pair<string, sEntry*> t2 = pair<string, sEntry*>("$t2", NULL);
  pair<string, sEntry*> t3 = pair<string, sEntry*>("$t3", NULL);
  pair<string, sEntry*> t4 = pair<string, sEntry*>("$t4", NULL);
  pair<string, sEntry*> t5 = pair<string, sEntry*>("$t5", NULL);
  pair<string, sEntry*> s0 = pair<string, sEntry*>("$s0", NULL);
  pair<string, sEntry*> s1 = pair<string, sEntry*>("$s1", NULL);
  pair<string, sEntry*> s2 = pair<string, sEntry*>("$s2", NULL);
  pair<string, sEntry*> s3 = pair<string, sEntry*>("$s3", NULL);
  pair<string, sEntry*> s4 = pair<string, sEntry*>("$s4", NULL);
  free_reg.push(t1);
  free_reg.push(t2);
  free_reg.push(t3);
  free_reg.push(t4);
  free_reg.push(t0);
  free_reg.push(t5);
  free_reg.push(s0);
  free_reg.push(s1);
  free_reg.push(s2);
  free_reg.push(s3);
  free_reg.push(s4);
  pair<string, string> _t0 = pair<string, string>("$t0", "");
  pair<string, string> _t1 = pair<string, string>("$t1", "");
  pair<string, string> _t2 = pair<string, string>("$t2", "");
  pair<string, string> _t3 = pair<string, string>("$t3", "");
  pair<string, string> _t4 = pair<string, string>("$t4", "");
  pair<string, string> _t5 = pair<string, string>("$t5", "");
  pair<string, string> _s0 = pair<string, string>("$s0", "");
  pair<string, string> _s1 = pair<string, string>("$s1", "");
  pair<string, string> _s2 = pair<string, string>("$s2", "");
  pair<string, string> _s3 = pair<string, string>("$s3", "");
  pair<string, string> _s4 = pair<string, string>("$s4", "");
  reg.insert(_t0);
  reg.insert(_t1);
  reg.insert(_t2);
  reg.insert(_t3);
  reg.insert(_t4);
  reg.insert(_t5);
  reg.insert(_s0);
  reg.insert(_s1);
  reg.insert(_s2);
  reg.insert(_s3);
  reg.insert(_s4);
}

string get_reg(qid temp){
  //checking if the temp is already in a register
  auto it = reg.begin();
  string r;
  for(; it!= reg.end(); it++){
    if (it->second == temp.first) {
      r = it->first;
      break;
    }
  }
  if(it == reg.end())r = string("");
  if( r!=""){ return r; }

  //Check if we have a free_reg
  if(free_reg.size()) {

    pair<string, sEntry*> t = free_reg.front(); // register
    free_reg.pop();
          
    int offset1 = temp.second->offset;

    if(curr_func!="main") offset1 = offset1+76;//maybe for local variables
    r = t.first;

    // store the value from location to register
    putln("li $s6, "+ to_string(offset1));       // put the offset in $s6
    putln("sub $s7, $fp, $s6");        //$s7 contains address of value
    putln("lw "+ r +", 0($s7)"); // load value at address $s7 to r
    t.second  = temp.second;
    used_reg.push(t);
    string tmp = "_"  + r;
    reg[tmp] = temp.first;
  }
  else{// no available register
    pair<string, sEntry*> t = used_reg.front();
    used_reg.pop();
    // save the values present in the used register
    sEntry* curr_sym_tab = t.second;
    r = t.first;
    int offset = curr_sym_tab->offset;
    if(curr_func!="main") offset = offset+76;
    //store the current value in r in the register s7 with the proper offset to frame
    putln("li $s6, "+ to_string(offset));
    putln("sub $s7, $fp, $s6");        
    putln("sw "+ r +", 0($s7)");

    //now we can  use the register to store the tmp
    offset = temp.second->offset;
    if(curr_func!="main") offset = offset+76;

    // now we store value from the location in the stack to r
    putln("li $s6, "+ to_string(offset) );       // put the offset in $s6
    putln("sub $s7, $fp, $s6"); 
    putln("lw "+ r +", 0($s7)");
    t.second  = temp.second;
    used_reg.push(t);
    string tmp = "_" + r;
    reg[tmp] = temp.first;
  }
}
void array_to_reg(qid tmp, string regtmp){//4 * size + offset
    if(curr_func == "main") {
      putln("li $s6, "+to_string(tmp.second->size) );
      putln("sub $s7, $fp, $s6");
      putln("lw $t8, 0($s7)");
      putln("li $t7, 4");
      putln("mult $t8, $t7");
      putln("mflo $t7");
      putln("li $s6, " + to_string(tmp.second->offset)); 
      putln("add $s6, $s6, $t7");
      putln("sub $s7, $fp, $s6"); 
    }else{
      putln("li $s6, "+to_string(tmp.second->size) );
      putln("addi $s6, 76");
      putln("sub $s7, $fp, $s6");
      putln("lw $t8, 0($s7)");
      putln("li $t7, 4");
      putln("mult $t8, $t7");
      putln("mflo $t7");
      putln("li $s6, "+ to_string(tmp.second->offset));
      putln("addi $s6, 76");
      putln("sub $s7, $fp, $s6");
      putln("lw $t8, 0($s7)");
      putln("sub $s7, $t8, $t7");
    }  
    putln("lw "+ regtmp +", 0($s7)");
}

// flush all registers on jump
void save_reg(){
  pair<string, sEntry*> t;
  while(used_reg.size()){
    t = used_reg.front();
    used_reg.pop();
    // Update the exisiting identifier value from reset_reg
    sEntry* curr_sym_tab = t.second;
    string r = t.first;
    int offset = curr_sym_tab->offset;
    if(curr_func!="main") offset = offset+76;

    putln("li $s6, "+ to_string(offset));
    putln("sub $s7, $fp, $s6"); 
    putln("sw "+ r +", 0($s7)");
    t.second  = NULL;
    free_reg.push(t);
    string tmp = "_" + r;
    reg[tmp] = "";
  }
}

void assignment_exp_asm(int i){//helper function for comparison
  if (IRcode[i].id2.second == NULL) {
          putln("addi $t9, $0, " + IRcode[i].id2.first);
          r1 = "$t9";
  }
  else if(IRcode[i].id2.second->is_init == -5){
      r1 = string("$t6");
      array_to_reg(IRcode[i].id2, r1);
  }
  else r1 = get_reg(IRcode[i].id2);

  if(IRcode[i].id1.second->is_init == -5){
    r2 = string("$t7");
    array_to_reg(IRcode[i].id1, r2);
  }
  else  r2 = get_reg(IRcode[i].id1);
  r3 = get_reg(IRcode[i].res);
  return ;
}

void operator_asm1(int i){//helper function for arithmetic
  r1 = get_reg(IRcode[i].res);
  if(IRcode[i].id1.second->is_init == -5) r2 = string("$t6");
  else r2 = get_reg(IRcode[i].id1);
  if (IRcode[i].id1.second != NULL) {
    if (IRcode[i].id1.second->is_init == -5) {
      array_to_reg(IRcode[i].id1, r2);
    }
  }
  return;
}

void operator_asm2(int i){//helper function for arithmetic
  if(IRcode[i].id2.second->is_init == -5) {
    r3 = string("$t7");
    array_to_reg(IRcode[i].id2, r3);
  }
  else r3 = get_reg(IRcode[i].id2);
}
void call_seq_asm_code(){ //using callee-save method
    // store return address of the caller
    putln("sw $ra, 0($sp)");
    // store the frame pointe of the caller
    putln("sw $fp, 4($sp)");
    // set the frame pointer of the callee    8($sp)
    putln("la $fp, 72($sp)");
    // storing the remaining registers
    putln("sw $t0, 12($sp)");
    putln("sw $t1, 16($sp)");
    putln("sw $t2, 20($sp)");
    putln("sw $t3, 24($sp)");
    putln("sw $t4, 28($sp)");
    putln("sw $t5, 32($sp)");
    putln("sw $t6, 36($sp)");
    putln("sw $t7, 40($sp)");
    putln("sw $t8, 44($sp)");
    putln("sw $t9, 48($sp)");
    putln("sw $s0, 52($sp)");
    putln("sw $s1, 56($sp)");
    putln("sw $s2, 60($sp)");
    putln("sw $s3, 64($sp)");
    putln("sw $s4, 68($sp)");
}
void return_seq_asm_code(){ //using callee-save method
      // load environment pointers
      putln("lw $ra, 0($sp)");
      putln("lw $fp, 4($sp)");
      putln("lw $a0, 8($sp)");
      // Restoring all the Registers
      putln("lw $t0, 12($sp)");
      putln("lw $t1, 16($sp)");
      putln("lw $t2, 20($sp)");
      putln("lw $t3, 24($sp)");
      putln("lw $t4, 28($sp)");
      putln("lw $t5, 32($sp)");
      putln("lw $t6, 36($sp)");
      putln("lw $t7, 40($sp)");
      putln("lw $t8, 44($sp)");
      putln("lw $t9, 48($sp)");
      putln("lw $s0, 52($sp)");
      putln("lw $s1, 56($sp)");
      putln("lw $s2, 60($sp)");
      putln("lw $s3, 64($sp)");
      putln("lw $s4, 68($sp)");
}
void print_int_asm(){
  putln("li $v0, 1");
  putln("syscall");
  argcount = 0; 
}
void print_float_asm(){
  putln("mov $f12, $a0");
  putln("li $v0, 2");
  putln("syscall");
  argcount = 0;   
}
void print_string_asm(){
  putln("li $v0, 4");
  putln("syscall");
  argcount = 0;  
}
void scan_int_asm(){
        putln("li $v0, 5");
        putln("syscall");
        putln("move " + r1 + ", $v0");  
}
void scan_float_asm(){
        putln("li $v0, 6");
        putln("syscall");
        putln("move " + r1 + ", $f0");  
}
void scan_string_asm(){
        putln("la $a0, stringspace");
        putln("li $a1, 1024");
        putln("li $v0, 8 ");
        putln("syscall");
        putln("la $v0, stringspace");
        putln("move " + r1 + ", $v0");  
}
void read_file(){
        putln("li $v0, 13");//syscall 13 - open file
        putln("li $a1, 0"); //set to read mode
        putln("li $a2, 0");
        putln("syscall"); 
        putln("move $s0, $v0"); //saves filedescriptor
        putln("li $a1, 0"); //set to read mode 
        putln("li $a2, 0");
        putln("syscall"); 
        putln("move $s6, $v0"); //saves filedescriptor
        putln("li $v0, 14");
        putln("move $a0, $s6");
        putln("la $a1, reservedspace");
        putln("li $a2, 1024");
        putln("syscall");
        putln("li $v0, 4");
        putln("la $a0, reservedspace");
        putln("syscall");
        putln("li $v0 16");
        putln("move $a0, $s6");
        putln("syscall");
        argcount = 0;
}
void write_file(){
        putln("li $v0, 13");//syscall 13 - open file
        putln("li $a1, 0"); //set to read mode 
        putln("li $a2, 0");
        putln("syscall");  
        putln("move $s6, $v0"); //saves filedescriptor
        putln("li $v0, 15");
        putln("move $a0, $s6");
        putln("li $a2, 30");
        putln("syscall");
        putln("li $v0 16");
        putln("move $a0, $s6");
        putln("syscall");
        argcount = 0;  
}