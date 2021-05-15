void swap(int x,int y);
void swap(int a, int b){
	int tmp;
    tmp = a;
    a = b;
    b = tmp;
}
int main(){
	
  int c,d;
  swap(c,d);
	return 0;
}