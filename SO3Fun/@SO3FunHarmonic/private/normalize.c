// Normalize fourier coefficients
static void NORMALIZE( const mxDouble bandwidth, mxComplexDouble *fhat )
{
  int l,k,u,u_square;
  const int N = bandwidth;
  mxDouble sqrt_u;
  for (l=0; l<=N; l++)
  {
    u = 2*l+1;
    u_square = u*u;
    sqrt_u = sqrt(u);
    for (k=0; k<u_square; k++)
    {
      fhat[0].real = fhat[0].real*sqrt_u;
      fhat[0].imag = fhat[0].imag*sqrt_u;
      fhat ++;
    }
  }
}