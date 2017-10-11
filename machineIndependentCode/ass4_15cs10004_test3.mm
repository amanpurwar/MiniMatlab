// test functions
int test = 4;


int fibonacci (int n)
{
	int term1,term2,sum;
	if (n==0)
		return 0;
	if(n==1)
		return 1;

			term1=fibonacci(n-1);
			term2=fibonacci(n-2);
			sum=term1+term2;
			return sum;


}
void main ()
{
	int n = 4;
	int fib;
	fib = fibonacci(n);
	return;
}