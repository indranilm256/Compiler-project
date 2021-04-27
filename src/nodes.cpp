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
  //cout << "nnn\n";
  //Node* new_node = makeNewNode(str);
  //cout << "jjj\n";
  // checking '\n' character
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

  // printing sting token
  if(node_name[0] == '"'){
    node_name = node_name.substr(1, node_name.size()-2);
    //fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id,node_name.c_str() );
  }
  // else{
  //   fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id,node_name.c_str() );
  // }
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
  //return new_node;
}

void Node :: mknode(char *opr, Node *l, Node *r) {
  //Node* new_node = makeNewNode(str);
  int opr_id = ID_for_Node();
  //char *opr_str = opr;
  if(opr){
    fprintf(digraph, "\t%d [label=\"%s\"];\n", opr_id,opr);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
  if(l) fprintf(digraph, "\t%d -> %d;\n", node_id, l->node_id);
  if(opr)fprintf(digraph, "\t%d -> %d;\n", node_id, opr_id);
  if(r)fprintf(digraph, "\t%d -> %d;\n", node_id, r->node_id);
  //return new_node;
}

void Node :: mknode(Node *l,Node *m, Node *r) {
  //Node* new_node = makeNewNode(str);
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
  if(l) fprintf(digraph, "\t%d -> %d;\n", node_id, l->node_id);
  if(m) fprintf(digraph, "\t%d -> %d;\n", node_id, m->node_id);
  if(r)fprintf(digraph, "\t%d -> %d;\n", node_id, r->node_id);
  //return new_node;
}

void Node :: mknode(char *opr1,char *opr3, Node *l,char *opr2) {
  /*Node* new_node = makeNewNode(str);
  int opr1_id = ID_for_Node();
  char *opr1_str = opr1;
  int opr3_id = ID_for_Node();
  char *opr3_str = opr3;
  int opr2_id = ID_for_Node();
  char *opr2_str = opr2;
  if(opr1){

    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr1_id, opr1_str);
  }
  if(opr3){

    fprintf(digraph, "\t%d [label=\"%s\"];\n", opr3_id, opr3_str);
  }

  if(opr2){

    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr2_id, opr2_str);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id, node_name.c_str());
  if(opr1) fprintf(digraph, "\t%d -> %d;\n",node_id, opr1_id);
  if(opr3) fprintf(digraph, "\t%d -> %d;\n",node_id, opr3_id);
  if(l)fprintf(digraph, "\t%d -> %d;\n",node_id, l->node_id);
  if(opr2) fprintf(digraph, "\t%d -> %d;\n",node_id, opr2_id);
  return new_node;*/
  //Node* new_node = makeNewNode(str);
  int opr1_id = ID_for_Node();
 // char *opr1_str = opr1;
  int opr2_id = ID_for_Node();
 // char *opr3_str = opr3;
  int opr3_id = ID_for_Node();
  //char *opr2_str = opr2;
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
  /*Node* new_node = makeNewNode(str);
  int opr_id = ID_for_Node();
  char *opr_str = opr;
  if(opr){
    fprintf(digraph, "\t%d [label=\"%s\"];\n",opr_id,opr_str);
  }
  fprintf(digraph, "\t%d [label=\"%s\"];\n",node_id, node_name.c_str());
  if(a1) fprintf(digraph, "\t%d -> %d;\n",node_id,a1->node_id);
  if(a2) fprintf(digraph, "\t%d -> %d;\n",node_id,a2->node_id);
  if(a3) fprintf(digraph, "\t%d -> %d;\n",node_id,a3->node_id);
  if(a4) fprintf(digraph, "\t%d -> %d;\n",node_id,a4->node_id);
  if(opr) fprintf(digraph, "\t%d -> %d;\n",node_id,opr_id);
  return new_node;*/
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
  /*Node* new_node = makeNewNode(str);
  fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id,node_name.c_str() );
  int bracketId = ID_for_Node();
  if(flag){fprintf(digraph, "\t%d [label=\"[ ]\"];\n", bracketId);}
  else{fprintf(digraph, "\t%d [label=\"( )\"];\n", bracketId);}
  if(a) fprintf(digraph, "\t%d -> %d;\n",node_id, a->node_id);
  fprintf(digraph, "\t%d -> %d;\n",node_id, bracketId);
  return new_node;*/
    fprintf(digraph, "\t%d [label=\"%s\"];\n", node_id, node_name.c_str());
    int bracket_id = ID_for_Node();
    if(flag){ fprintf(digraph, "\t%d [label=\"[ ]\"];\n", bracket_id);}
    else{ fprintf(digraph, "\t%d [label=\"( )\"];\n", bracket_id);}
    if(a) fprintf(digraph, "\t%d -> %d;\n", node_id, a->node_id);
    fprintf(digraph, "\t%d -> %d;\n", node_id,bracket_id);
}








  
