/* find points in spherical grid */


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

#include "S2Grid.c"

/* Input Arguments */

#define	ytheta_IN  prhs[0]
#define	iytheta_IN prhs[1]
#define	yrho_IN	   prhs[2]
#define	prho_IN	   prhs[3]
#define	xtheta_IN  prhs[4]
#define	xrho_IN    prhs[5]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  S2Grid S2G;
  double *xtheta, *xrho; 
  mwSize ix,nx,nytheta,nyrho; 
  double *ind;
  
  
  int *iytheta;
     
  /* Check for proper number of arguments */
    
  if (nrhs != 6) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } 

  /* get input dimensions */ 
  nx = mxGetM(xtheta_IN) * mxGetN(xtheta_IN);
  nytheta = mxGetM(ytheta_IN) * mxGetN(ytheta_IN);
  nyrho = mxGetM(yrho_IN) * mxGetN(yrho_IN);

  /* Assign pointers to the various parameters */
  S2Grid_init(&S2G, mxGetPr(yrho_IN), mxGetPr(ytheta_IN), nytheta,
	      (int*) mxGetData(iytheta_IN), *((double*) mxGetPr(prho_IN)));

  xtheta = mxGetPr(xtheta_IN); 
  xrho = mxGetPr(xrho_IN);

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(nx,1,0);
  ind = mxGetPr(plhs[0]);

  /* find */
  for (ix=0;ix<nx;ix++)
    ind[ix] = 1 + S2Grid_find(&S2G, xtheta[ix], xrho[ix]);

  /* free memory */
  S2Grid_finalize(&S2G);

}
