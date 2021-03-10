#include "nodes.h"

extern FILE *digraph;

int ID_for_Node() {
  static int num = 0;
  num += 1;
  return num;
}

void graphStart() {
  fprintf(digraph, "digraph G {\n");
  fprintf(digraph, "\tordering=out;\n");
}

void graphEnd() {
  fprintf(digraph, "}\n");
}

node *non_terminal_symbol_type1(char *str,char *opr, node *l, node *r) {
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  int opr_id = ID_for_Node();
  char *opr_str = opr;
  if(opr){
    fprintf(digraph, "\t%lu [label=\"%s\"];\n", opr_id, opr_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id, new_node->node_name.c_str());
  if(l) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, l->node_id);
  if(opr) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, opr_id);
  if(r)fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, r->node_id);
  return new_node;
}

node *non_terminal_symbol_type2(char *str,node *l,node *m, node *r) {
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id, new_node->node_name.c_str());
  if(l) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, l->node_id);
  if(m) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, m->node_id);
  if(r)fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, r->node_id);
  return new_node;
}


node *non_terminal_symbol_type3(char *str,char *opr1,char *opr3, node *l,char *opr2) {
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  int opr1_id = ID_for_Node();
  char *opr1_str = opr1;
  int opr3_id = ID_for_Node();
  char *opr3_str = opr3;
  int opr2_id = ID_for_Node();
  char *opr2_str = opr2;
  if(opr1){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", opr1_id, opr1_str);
  }
  if(opr3){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", opr3_id, opr3_str);
  }

  if(opr2){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", opr2_id, opr2_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id, new_node->node_name.c_str());
  if(opr1) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, opr1_id);
  if(opr3) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, opr3_id);
  if(l)fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, l->node_id);
  if(opr2) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, opr2_id);
  return new_node;
}

node *non_terminal_symbol_type4(char *str,node *a1,node *a2, node *a3, node*a4, char* opr) {
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  int opr_id = ID_for_Node();
  char *opr_str = opr;
  if(opr){
    fprintf(digraph,"\t%lu [label=\"%s\"];\n",opr_id,opr_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id, new_node->node_name.c_str());
  if(a1) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a1->node_id);
  if(a2) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a2->node_id);
  if(a3)fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a3->node_id);
  if(a4) fprintf(digraph,"\t%lu -> %lu;\n",new_node->node_id,a4->node_id);
  if(opr) fprintf(digraph,"\t%lu -> %lu;\n",new_node->node_id,opr_id);
  return new_node;
}

node *non_terminal_symbol_type5(char *str,node *a1,node *a2, node *a3, node*a4, node* a5) {
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id, new_node->node_name.c_str());
  if(a1) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a1->node_id);
  if(a2) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a2->node_id);
  if(a3)fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a3->node_id);
  if(a4) fprintf(digraph,"\t%lu -> %lu;\n",new_node->node_id, a4->node_id);
  if(a5) fprintf(digraph,"\t%lu -> %lu;\n",new_node->node_id, a5->node_id);
  return new_node;
}

node *terminal(char *str) {
  node *new_node = new node;
  new_node->node_name=str;
  new_node->node_id = ID_for_Node();
  // checking '\n' character
  // the loopr run til len because the last character is ""
  stringstream ss;
  for(int i=0; i < new_node->node_name.size(); ++i){
    if(new_node->node_name[i]=='\\'){
      char tmp = '\\';
      ss << tmp;
    }
    ss << new_node->node_name[i];
  }
  new_node->node_name = ss.str();

  // printing sting token
  if(str[0] == '"'){
    new_node->node_name = new_node->node_name.substr(1, new_node->node_name.size()-2);
    fprintf(digraph, "\t%lu [label=\"\\\"%s\\\"\"];\n", new_node->node_id,new_node->node_name.c_str() );
  }
  else{
    fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id,new_node->node_name.c_str() );
  }
  return new_node;
}

node *paranthesis_non_terminal(char *str, node *a) {
  node *new_node = new node;
  new_node->node_name=str;
  new_node->node_id = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id,new_node->node_name.c_str() );
  int newBracketId = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"( )\"];\n", newBracketId );
  if(a) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a->node_id);
  fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, newBracketId);
  return new_node;
}
node *square_non_terminal(char *str, node *a) {
  node *new_node = new node;
  new_node->node_name=str;
  new_node->node_id = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", new_node->node_id,new_node->node_name.c_str() );
  int newBracketId = ID_for_Node();
  fprintf(digraph, "\t%lu [label=\"[ ]\"];\n", newBracketId );
  if(a) fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, a->node_id);
  fprintf(digraph, "\t%lu -> %lu;\n", new_node->node_id, newBracketId);
  return new_node;
}


