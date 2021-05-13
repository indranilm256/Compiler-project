double bar(int a){
    int b;
    printn(a);
}
int foo(int a){
    int b=a;
    bar(b);
}
int main(){
    int a;
    scanf("%d", &a);
    foo(a);
    return 0;

}