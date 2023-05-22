/*
 * Transform the integer which includes the flags to boolean vector.
 * flags:  2^0 -> fhat are the fourier coefficients of a real valued function
 *         2^1 -> make size of result even
 *         2^2 -> use L_2-normalized Wigner-D functions
 *         2^3 -> precompute Wigner-d Matrices      (not implemented yet)
 */

void get_flags(mxDouble number, bool flags[7]) 
{
  for (int i = 6; i>=0; i--)
  {
    if(number >= pow(2,i))
    {
      number = number-pow(2,i);
      flags[i]=1;
    }
    else{
      flags[i]=0;
    }
  }
}