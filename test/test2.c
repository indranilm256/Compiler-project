
void fewParam(int* a,int* b,int* c){
    int temp=*a;
    *a=*b;
    *b=*c;
    *c=temp;

}
void moreParam(int* a,int* b){
    int temp=*a;
    *a=*b;
    *b=temp;
}

int main(){
    int* p;
    p = (int*)malloc(8);
    return 0;
}