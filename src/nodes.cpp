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
 
node* makeNewNode(char *str){
  node *new_node = new node;
  new_node->node_name = str;
  new_node->node_id = ID_for_Node();
  return new_node;
}

void labelMaker(int x,const char* str){
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", x, str);
}
void edgeMaker(int node_id,int n){
  fprintf(digraph, "\t%lu -> %lu;\n", node_id, n);
}

node *mkleaf(char *str) {
  //cout << "nnn\n";
  node* new_node = makeNewNode(str);
  //cout << "jjj\n";
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
    labelMaker(new_node->node_id,new_node->node_name.c_str() );
  }
  else{
    labelMaker(new_node->node_id,new_node->node_name.c_str() );
  }
  return new_node;
}

node *mknode(char *str,char *opr, node *l, node *r) {
  node* new_node = makeNewNode(str);
  int opr_id = ID_for_Node();
  char *opr_str = opr;
  if(opr){
    labelMaker(opr_id,opr_str);
  }
  labelMaker(new_node->node_id, new_node->node_name.c_str());
  if(l) edgeMaker(new_node->node_id,l->node_id);
  if(opr) edgeMaker(new_node->node_id,opr_id);
  if(r)edgeMaker(new_node->node_id,r->node_id);
  return new_node;
}

node *mknode(char *str,node *l,node *m, node *r) {
  node* new_node = makeNewNode(str);
  labelMaker(new_node->node_id, new_node->node_name.c_str());
  if(l) edgeMaker(new_node->node_id,l->node_id);
  if(m) edgeMaker(new_node->node_id,m->node_id);
  if(r)edgeMaker(new_node->node_id,r->node_id);
  return new_node;
}


node *mknode(char *str,char *opr1,char *opr3, node *l,char *opr2) {
  node* new_node = makeNewNode(str);
  int opr1_id = ID_for_Node();
  char *opr1_str = opr1;
  int opr3_id = ID_for_Node();
  char *opr3_str = opr3;
  int opr2_id = ID_for_Node();
  char *opr2_str = opr2;
  if(opr1){

    labelMaker(opr1_id, opr1_str);
  }
  if(opr3){

    labelMaker( opr3_id, opr3_str);
  }

  if(opr2){

    labelMaker(opr2_id, opr2_str);
  }
  labelMaker(new_node->node_id, new_node->node_name.c_str());
  if(opr1) edgeMaker(new_node->node_id, opr1_id);
  if(opr3) edgeMaker(new_node->node_id, opr3_id);
  if(l)edgeMaker(new_node->node_id, l->node_id);
  if(opr2) edgeMaker(new_node->node_id, opr2_id);
  return new_node;
}

node *mknode(char *str,node *a1,node *a2, node *a3, node*a4, char* opr) {
  node* new_node = makeNewNode(str);
  int opr_id = ID_for_Node();
  char *opr_str = opr;
  if(opr){
    labelMaker(opr_id,opr_str);
  }
  labelMaker(new_node->node_id, new_node->node_name.c_str());
  if(a1) edgeMaker(new_node->node_id,a1->node_id);
  if(a2) edgeMaker(new_node->node_id,a2->node_id);
  if(a3) edgeMaker(new_node->node_id,a3->node_id);
  if(a4) edgeMaker(new_node->node_id,a4->node_id);
  if(opr) edgeMaker(new_node->node_id,opr_id);
  return new_node;
}

node *mknode(char *str,node *a1,node *a2, node *a3, node*a4, node* a5) {
  node* new_node = makeNewNode(str);
  labelMaker(new_node->node_id, new_node->node_name.c_str());
  if(a1) edgeMaker(new_node->node_id, a1->node_id);
  if(a2) edgeMaker(new_node->node_id,a2->node_id);
  if(a3)edgeMaker(new_node->node_id,  a3->node_id);
  if(a4) edgeMaker(new_node->node_id, a4->node_id);
  if(a5) edgeMaker(new_node->node_id, a5->node_id);
  return new_node;
}
node *mknode(char *str, node *a, int flag) { 
  node* new_node = makeNewNode(str);
  labelMaker( new_node->node_id,new_node->node_name.c_str() );
  int bracketId = ID_for_Node();
  if(flag){fprintf(digraph, "\t%lu [label=\"[ ]\"];\n", bracketId);}
  else{fprintf(digraph, "\t%lu [label=\"( )\"];\n", bracketId);}
  if(a) edgeMaker(new_node->node_id, a->node_id);
  edgeMaker(new_node->node_id, bracketId);
  return new_node;
}







