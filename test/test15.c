int* func(){
    int i=2;
    return &i;
}

int main(){
    int *local=func();
    printn(*local);
    return 0;
}