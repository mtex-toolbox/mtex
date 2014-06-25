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
#define	e_IN	prhs[4]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  S1Grid S1G;
  double *x;
  mwSize nx; 
  double epsilon;
  int ix, *indx;
  buffer ind;
  mwIndex *irs,*jcs;
  mxLogical *sr;
    
  /* Check for proper number of arguments */
  if (nrhs != 5) { 
    mexErrMsgTxt("Four input arguments required."); 
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments."); 
  } 
    
  /* get input */ 
  nx = mxGetM(X_IN) * mxGetN(X_IN);

  S1Grid_init(&S1G,mxGetPr(Y_IN),
	      mxGetM(Y_IN) * mxGetN(Y_IN),
	      *(double*) mxGetPr(MIN_IN),
	      *(double*) mxGetPr(P_IN));

  x = mxGetPr(X_IN); 
  epsilon = *(double*) mxGetPr(e_IN);

  /* init buffers */
  buffer_init(&ind,50*nx);
  indx = (int*) malloc(sizeof(int)*(nx+1));

  /* find */
  for (ix=0;ix<nx;ix++){
    indx[ix] = ind.used;
    S1Grid_find_region(&S1G,x[ix],epsilon,&ind);
  }
  indx[nx] = ind.used;

  /* generate sparse output matrix */
  plhs[0] = mxCreateSparseLogicalMatrix(S1G.n,nx,1+indx[nx]);

  sr  = mxGetLogicals(plhs[0]); /* elements */
  irs = mxGetIr(plhs[0]); /* rows  - y */
  jcs = mxGetJc(plhs[0]); /* columns - x */

  for (ix=0;ix<indx[nx];ix++){
    sr[ix] = 1;
    irs[ix] = ind.data[ix];
  }

  for (ix=0;ix<=nx;ix++)
    jcs[ix] = indx[ix];

  /* free memory */
  free(indx);
  buffer_finalize(&ind);
  S1Grid_finalize(&S1G);

}


