#include "nodes.h"

extern FILE *digraph;

void graphStart() {
  fprintf(digraph, "digraph G {\n");
  fprintf(digraph, "\tordering=out;\n");
}

void graphEnd() {
  fprintf(digraph, "}\n");
}

int ID_for_Node() {
  static int num = 0;
  num += 1;
  return num;
}

void Node :: mkleaf() {
  // the loopr run til len because the last character is ""
  stringstream ss;
  for(int i=0; i < node_name.size(); ++i){
    if(node_name[i]=='\\'){
      char tmp = '\\';
      ss << tmp;
    }
    ss << node_name[i];
  }
  node_name = ss.str();

  // printing string token no.
  if(node_name[0] == '"'){
    node_name = node_name.substr(1, node_name.size()-2);
    
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
}

void Node :: mknode(char *opr, Node *l, Node *r) {
  int opr_id = ID_for_Node();
  if(opr){
    fprintf(digraph, "\t%d [label=\"%s\"];\n", opr_id,opr);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
  if(l) fprintf(digraph, "\t%d -> %d;\n", node_id, l->node_id);
  if(opr)fprintf(digraph, "\t%d -> %d;\n", node_id, opr_id);
  if(r)fprintf(digraph, "\t%d -> %d;\n", node_id, r->node_id);
}

void Node :: mknode(Node *l,Node *m, Node *r) {
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
  if(l) fprintf(digraph, "\t%d -> %d;\n", node_id, l->node_id);
  if(m) fprintf(digraph, "\t%d -> %d;\n", node_id, m->node_id);
  if(r)fprintf(digraph, "\t%d -> %d;\n", node_id, r->node_id);

}

void Node :: mknode(char *opr1,char *opr3, Node *l,char *opr2) {
  
  int opr1_id = ID_for_Node();
 
  int opr2_id = ID_for_Node();
 
  int opr3_id = ID_for_Node();
  if(opr1){
    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr1_id, opr1);
  }
  if(opr3){
    fprintf(digraph, "\t%d [label=\"%s\"];\n", opr3_id, opr3);
  }
  if(opr2){
    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr2_id, opr2);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id, node_name.c_str());
  if(opr1) fprintf(digraph, "\t%d -> %d;\n",node_id, opr1_id);
  if(opr3) fprintf(digraph, "\t%d -> %d;\n",node_id, opr3_id);
  if(l)fprintf(digraph, "\t%d -> %d;\n",node_id, l->node_id);
  if(opr2) fprintf(digraph, "\t%d -> %d;\n",node_id, opr2_id);
}

void Node :: mknode(Node *a1,Node *a2, Node *a3, Node*a4, char* opr) {
  int opr_id = ID_for_Node();
  if(opr){
    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr_id,opr);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id, node_name.c_str());
  if(a1) fprintf(digraph, "\t%d -> %d;\n",node_id,a1->node_id);
  if(a2) fprintf(digraph, "\t%d -> %d;\n",node_id,a2->node_id);
  if(a3) fprintf(digraph, "\t%d -> %d;\n",node_id,a3->node_id);
  if(a4) fprintf(digraph, "\t%d -> %d;\n",node_id,a4->node_id);
  if(opr) fprintf(digraph, "\t%d -> %d;\n",node_id,opr_id);
}

void Node :: mknode(Node *a1,Node *a2, Node *a3, Node*a4, Node* a5) {
  fprintf(digraph, "\t%d [label=\"%s\"];\n",  node_id, node_name.c_str());
  if(a1)fprintf(digraph, "\t%d -> %d;\n", node_id, a1->node_id);
  if(a2)fprintf(digraph, "\t%d -> %d;\n", node_id, a2->node_id);
  if(a3)fprintf(digraph, "\t%d -> %d;\n", node_id, a3->node_id);
  if(a4)fprintf(digraph, "\t%d -> %d;\n", node_id, a4->node_id);
  if(a5)fprintf(digraph, "\t%d -> %d;\n", node_id, a5->node_id);
}
void Node :: mknode(Node *a, int flag) { 
    fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
    int bracket_id = ID_for_Node();
    if(flag){ fprintf(digraph, "\t%d [label=\"[ ]\"];\n", bracket_id);}
    else{ fprintf(digraph, "\t%d [label=\"( )\"];\n", bracket_id);}
    if(a) fprintf(digraph, "\t%d -> %d;\n", node_id, a->node_id);
    fprintf(digraph, "\t%d -> %d;\n", node_id,bracket_id);
}








  
