/**
 * @file   SO3Grid_find.c
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

#include "SO3Grid.c"

/* Input Arguments */

#define	alpha_IN   prhs[0]
#define	beta_IN    prhs[1]
#define	gamma_IN   prhs[2]
#define	sgamma_IN  prhs[3]
#define	igamma_IN  prhs[4]
#define ialphabeta_IN prhs[5]
#define	palpha_IN  prhs[6]
#define	pgamma_IN  prhs[7]
#define	xalpha_IN  prhs[8]
#define	xbeta_IN   prhs[9]
#define	xgamma_IN  prhs[10]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  SO3Grid SO3G;
  double *xalpha, *xbeta, *xgamma; 
  mwSize nx, nalpha, nbeta; 
  double *ind;
  double *dist;
  inddist id;
  int ix;
  
  
  /* Check for proper number of arguments */
    
  if (nrhs != 11) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments."); 
  } 

  /* get input dimensions */ 
  nx = mxGetM(xalpha_IN) * mxGetN(xalpha_IN);
  nalpha = mxGetM(alpha_IN) * mxGetN(alpha_IN);
  nbeta = mxGetM(beta_IN) * mxGetN(beta_IN);

  /* Assign pointers to the various parameters */
  SO3Grid_init(&SO3G, mxGetPr(alpha_IN), mxGetPr(beta_IN), mxGetPr(gamma_IN),
	       mxGetPr(sgamma_IN),
	       (int*) mxGetPr(igamma_IN), 
	       (int*) mxGetData(ialphabeta_IN), nbeta,
	       *((double*) mxGetPr(palpha_IN)),*((double*) mxGetPr(pgamma_IN)));

  xalpha = mxGetPr(xalpha_IN); 
  xbeta = mxGetPr(xbeta_IN);
  xgamma = mxGetPr(xgamma_IN);

  /* generate output matrix */
  plhs[0] = mxCreateDoubleMatrix(nx,1,0);
  ind = mxGetPr(plhs[0]);

  plhs[1] = mxCreateDoubleMatrix(nx,1,0);
  dist = mxGetPr(plhs[1]);

  /* find */
  for (ix=0;ix<nx;ix++){
    id = SO3Grid_find(&SO3G, xalpha[ix], xbeta[ix],xgamma[ix]);
    ind[ix] = 1 + id.ind;
    dist[ix] = id.dist;
  }

  /* free memory */
  SO3Grid_finalize(&SO3G);

}
