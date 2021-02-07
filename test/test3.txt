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

<<<<<<< HEAD

=======
int main()
{
	int arr[] = [1,9,2,8,3,7,4,6,5];
	mergeSort(arr,0,arr.size()-1);
	return 0;
>>>>>>> e1308c59108006158eb7832566c833393995822c
}
