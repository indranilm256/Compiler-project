void swap(int a,int b)
{
	int temp=a;
	b=a;
	a=temp;
}

int main(void)
{
	int a=1;
	int b=2;
	swap(a,b);
	printf("%d %d\n",a,b);
	return 0;
}
