int avg_of_int(int a,int b,int c)
{
	int avg=(a+b+c)/3;
	return avg;
}


int main()
{
	int a=1;
	int b=2;
	int c=3;
	int avg=avg_of_int(a,b,c);
	printf("%d\n",avg);
	return 0;
}
