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


#include <mex.h>
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
  double *sum;
  mwSize i1,i2; 
  mwSize n1,n2; 
  
  
  /* Check for proper number of arguments */
    
  if (nrhs != 8) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } 

  /* get input dimensions */ 
  n1 = mxGetM(a1_IN) * mxGetN(a1_IN);
  n2 = mxGetM(a2_IN) * mxGetN(a2_IN);

  a1 = mxGetPr(a1_IN); 
  b1 = mxGetPr(b1_IN);
  c1 = mxGetPr(c1_IN);
  d1 = mxGetPr(d1_IN);

  a2 = mxGetPr(a2_IN); 
  b2 = mxGetPr(b2_IN);
  c2 = mxGetPr(c2_IN);
  d2 = mxGetPr(d2_IN);

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(n1,n2,0);

  sum = mxGetPr(plhs[0]);

  for (i1=0;i1<n1;i1++) {
    
    for (i2=0;i2<n2;i2++) {

      sum[i1+n1*i2] = a1[i1]*a2[i2]+b1[i1]*b2[i2]+c1[i1]*c2[i2]+d1[i1]*d2[i2]; 

    }
  }
}

