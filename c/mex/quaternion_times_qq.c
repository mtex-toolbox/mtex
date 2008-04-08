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

#include "mex.h"
/* Input Arguments */

#define	a1_IN prhs[0]
#define	b1_IN prhs[1]
#define	c1_IN prhs[2]
#define	d1_IN prhs[3]
#define	a2_IN prhs[4]
#define	b2_IN prhs[5]
#define	c2_IN prhs[6]
#define	d2_IN prhs[7]

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  double *a1,*b1,*c1,*d1;
  double *a2,*b2,*c2,*d2;
  double *a3,*b3,*c3,*d3;
  mwSize i; 
  mwSize n1,n2; 
  
  
  /* Check for proper number of arguments */
    
  if (nrhs != 8) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 4) {
    mexErrMsgTxt("Too many output arguments."); 
  } 

  /* get input dimensions */ 
  n1 = mxGetM(a1_IN) * mxGetN(a1_IN);
  n2 = mxGetM(a2_IN) * mxGetN(a2_IN);

  if (n1 != n2)
    mexErrMsgTxt("Vectors must same size"); 

  a1 = mxGetPr(a1_IN); 
  b1 = mxGetPr(b1_IN);
  c1 = mxGetPr(c1_IN);
  d1 = mxGetPr(d1_IN);

  a2 = mxGetPr(a2_IN); 
  b2 = mxGetPr(b2_IN);
  c2 = mxGetPr(c2_IN);
  d2 = mxGetPr(d2_IN);

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(n1,1,0);
  plhs[1] = mxCreateDoubleMatrix(n1,1,0);
  plhs[2] = mxCreateDoubleMatrix(n1,1,0);
  plhs[3] = mxCreateDoubleMatrix(n1,1,0);

  a3 = mxGetPr(plhs[0]);
  b3 = mxGetPr(plhs[1]);
  c3 = mxGetPr(plhs[2]);
  d3 = mxGetPr(plhs[3]);

  for (i=0;i<n1;i++) {    
    a3[i] = a1[i]*a2[i]-b1[i]*b2[i]-c1[i]*c2[i]-d1[i]*d2[i]; 
    b3[i] = a1[i]*b2[i]+b1[i]*a2[i]+c1[i]*d2[i]-d1[i]*c2[i]; 
    c3[i] = a1[i]*c2[i]+c1[i]*a2[i]+d1[i]*b2[i]-b1[i]*d2[i]; 
    d3[i] = a1[i]*d2[i]+d1[i]*a2[i]+b1[i]*c2[i]-c1[i]*b2[i];
  }
}

