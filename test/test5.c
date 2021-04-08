int main(){
    char str1[5],str2[5];
    int arr1[5],arr2[5];
    int i;
    for(i=0;i<5;i++){
        char c=str1[i];
        str1[i]=str2[i];
        str2[i]=c;
    }

    for(i=0;i<5;i++){
        int c=arr1[i];
        arr1[i]=arr2[i];
        arr2[i]=c;
    }
    return 0;
}