/* find x in y*/


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

#include "S1Grid.c"

/* Input Arguments */

#define	Y_IN	prhs[0]
#define	MIN_IN	prhs[1]
#define	P_IN	prhs[2]
#define	X_IN	prhs[3]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  S1Grid S1G;
  double *x;
  mwSize nx; 
  int ix;
  double *ind;
    
  /* Check for proper number of arguments */
  if (nrhs != 4) { 
    mexErrMsgTxt("Four input arguments required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } 
    
  /* get input */ 
  nx = mxGetM(X_IN) * mxGetN(X_IN);

  S1Grid_init(&S1G,mxGetPr(Y_IN),
	      mxGetM(Y_IN) * mxGetN(Y_IN),
	      *(double*) mxGetPr(MIN_IN),
	      *(double*) mxGetPr(P_IN));

  x = mxGetPr(X_IN); 

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(nx,1,0);
  ind = mxGetPr(plhs[0]);


  /* find */
  for (ix=0;ix<nx;ix++)
    ind[ix] = 1 + S1Grid_find(&S1G,x[ix]);

  /* free memory */
  S1Grid_finalize(&S1G);

}
