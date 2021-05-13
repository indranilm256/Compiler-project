void printDigitName(int x)
{
    switch (x)
    {
        case 1:
            prints("One");
            return;
        case 2:
            prints("Two");
            return;
        case 3:
            prints("Three");
            return;
        default:
            prints("Unknown");
            return;
    }
}
 
int main()
{
    printDigitName(3);
    printDigitName(1);
    printDigitName(5);
    printDigitName(20);
    printDigitName(2);
 
    return 0;
}