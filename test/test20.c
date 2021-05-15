int foo(int x);
double bar(int a){
    if(a > 0) return foo(a-1);
    else return 0;
}
int foo(int a){
    int b=a;
    bar(b);
}
int main(){
    int a;
    scann(&a);
    foo(a);
    return 0;

}