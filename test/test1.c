
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
    int a=1;
    int b=2;
    int c=3;
    fewParam(&a,&b);
    moreParam(&a,&b,&c);
    return 0;
}