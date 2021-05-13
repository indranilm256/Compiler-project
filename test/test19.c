long long int fibonacci(int n){
	long long a=0;
	long long b =1;
   long long tmp;
   while(n){
      tmp=a;
      a=b;
      b = tmp+b;
      n=n-1;
   }
  return a;
}

int main(){
  int T,i,k;
  prints("input the number of test cases : ");
  scanf("%d", T);
  for(i=0;i<T;i=i+1){
     prints("input the index of fibonacci series : ");
     scanf("%d", k);
     prints("fibonacci number corresponding to your input value is :");
     printf(fibonacci(k));
  }
  return 0;
}
