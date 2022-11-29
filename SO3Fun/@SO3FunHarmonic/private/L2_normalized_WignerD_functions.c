/* 
 * The L2-norm of the Wigner-D functions is given by 
 *                  \|D_n^{k,l}(R)\|_{L2(SO3)}^2 = 1/(2n+1).
 * Hence we get L2-normalized Wigner-D functions by multiplying the Wigner-D 
 * function with sqrt(2n+1).
 * 
 * By evaluating linear combinations of L2-normalized Wigner-D functions
 *       \sum_{(n,k,l)\in I} fhat_n^{k,l} * sqrt(2n+1) * D_n^{k,l}(R)
 * we update the coefficients 
 *               fhat_n^{k,l}   ->   sqrt(2*n+1) * fhat_n^{k,l}
 * and compute the linear combination of the updated coefficients with the 
 * original Wigner-D functions.
 */

static void L2_normalized_WignerD_functions( const mxDouble bandwidth, mxComplexDouble *fhat )
{
  int n,k,u,u_square;
  const int N = bandwidth;
  double sqrt_u;
  for (n=0; n<=N; n++)
  {
    u = 2*n+1;
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