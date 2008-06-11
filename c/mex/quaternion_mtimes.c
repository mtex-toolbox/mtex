/**
 * @file   quaternion_mtimes.c
 * @author ralf
 * @date   Thu Oct 12 07:47:27 2007
 * 
 * @brief  find points in orientation grid
 * 
 * 
 */


/* If you are using a compiler that equates NaN to be zero, you must
 * compile this example using the flag  -DNAN_EQUALS_ZERO. For example:
 *
 *     mex -DNAN_EQUALS_ZERO fulltosparse.c
 *
 * This will correctly define the IsNonZero macro for your C compiler.
 */


#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif

#if !defined(SQR)
#define	SQR(A)	((A)*(A))
#endif

#include <mex.h>
#if !defined(MWSIZE_MAX)
typedef	int mwSize;
typedef	int mwIndex;
typedef	int mwSignedIndex;
#endif


/* Input Arguments */

#define	a_IN prhs[0]
#define	b_IN prhs[1]
#define	c_IN prhs[2]
#define	d_IN prhs[3]
#define	x_IN prhs[4]
#define y_IN prhs[5]
#define	z_IN prhs[6]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  double *a,*b,*c,*d;
  double *x,*y,*z;
  double *nx,*ny,*nz;
  double n,s;
  mwSize iq,iv; 
  mwSize nv,nq; 
  
  
  /* Check for proper number of arguments */
    
  if (nrhs != 7) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 3) {
    mexErrMsgTxt("Too many output arguments."); 
  } 

  /* get input dimensions */ 
  nv = mxGetM(x_IN) * mxGetN(x_IN);
  nq = mxGetM(a_IN) * mxGetN(a_IN);

  a = mxGetPr(a_IN); 
  b = mxGetPr(b_IN);
  c = mxGetPr(c_IN);
  d = mxGetPr(d_IN);

  x = mxGetPr(x_IN); 
  y = mxGetPr(y_IN);
  z = mxGetPr(z_IN);

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(nq,nv,0);
  plhs[1] = mxCreateDoubleMatrix(nq,nv,0);
  plhs[2] = mxCreateDoubleMatrix(nq,nv,0);

  nx = mxGetPr(plhs[0]);
  ny = mxGetPr(plhs[1]);
  nz = mxGetPr(plhs[2]);

  for (iq=0;iq<nq;iq++) {
    
    n = SQR(a[iq]) -  SQR(b[iq]) - SQR(c[iq]) -SQR(d[iq]);

    for (iv=0;iv<nv;iv++) {

      s = b[iq]*x[iv] + c[iq]*y[iv] + d[iq]*z[iv];
      
      nx[iq+nq*iv] = 2*a[iq] * (c[iq]*z[iv] - d[iq]*y[iv]) + 
	2*b[iq]*s + n * x[iv];
      ny[iq+nq*iv] = 2*a[iq] * (d[iq]*x[iv] - b[iq]*z[iv]) + 
	2*c[iq]*s + n * y[iv];
      nz[iq+nq*iv] = 2*a[iq] * (b[iq]*y[iv] - c[iq]*x[iv]) + 
	2*d[iq]*s + n * z[iv];
      
    }
  }
}

