int f (int a, int b, int c, int d, int e ){
  printf(a);
  printf(b);
  printf(c);
  printf(d);
  printf(e);
  int k = a + b + c + d + e;
  return k;
}

int g (int a, int b, int c){
  return a+b+c;
}

int main(){
  int a =1;
  int b = 2;
  int c = 3;
  int d = 4;
  int e = 5;
  int fa = f(a,b,c, d, e);
  printf(fa);
  return 0;

}
