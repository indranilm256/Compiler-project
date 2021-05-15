int factorial(int n){
  if(n == 1){return 1;}
  return n * factorial(n-1);
}

int main(){
  int a;
  a = 3;
  int b = factorial(a);
  return 0;
}
