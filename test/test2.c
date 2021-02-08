void mergeSort(int arr[],int l, int r)
{
	if(l>=r){
		return;
	}
	
	int m=l+(r-l)/2;
	mergeSort(arr,l,m);
	mergeSort(arr,m+1,r);
	merge(arr,l,m,r);
}

int main()
{
	int arr[] = [1,9,2,8,3,7,4,6,5];
	mergeSort(arr,0,arr.size()-1);
	return 0;
}
