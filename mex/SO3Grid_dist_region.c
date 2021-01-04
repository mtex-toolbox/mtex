/* find points in orientation grid */


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
#include <string.h>

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
#define	e_IN	   prhs[11]


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  SO3Grid SO3G;
  double *xalpha, *xbeta, *xgamma; 
  double epsilon;
  mwSize nx, nalpha, nbeta, ngamma; 
  buffer ind;
  double_buffer dist;
  int ix, *indx;
  mwIndex *irs,*jcs;
  double *pr;
  
  /* Check for proper number of arguments */
    
  if (nrhs != 12) { 
    mexErrMsgTxt("Seven input arguments required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } 



  /* get input dimensions */ 
  nx = mxGetM(xalpha_IN) * mxGetN(xalpha_IN);
  nalpha = mxGetM(alpha_IN) * mxGetN(alpha_IN);
  nbeta = mxGetM(beta_IN) * mxGetN(beta_IN);
  ngamma = mxGetM(gamma_IN) * mxGetN(gamma_IN);

  /* Assign pointers to the various parameters */
  SO3Grid_init(&SO3G, mxGetPr(alpha_IN), mxGetPr(beta_IN), mxGetPr(gamma_IN),
	       mxGetPr(sgamma_IN), 
	       (int*) mxGetPr(igamma_IN),
	       (int*) mxGetData(ialphabeta_IN), nbeta, 
	       *((double*) mxGetPr(palpha_IN)),
	       *((double*) mxGetPr(pgamma_IN)));

  /*SO3Grid_print(&SO3G);*/

  xalpha = mxGetPr(xalpha_IN); 
  xbeta = mxGetPr(xbeta_IN);
  xgamma = mxGetPr(xgamma_IN);
  epsilon = *(double*) mxGetPr(e_IN);

  /* init buffers */
  buffer_init(&ind,MIN(50,MIN(nx,ngamma))*MAX(nx,ngamma));
  double_buffer_init(&dist,MIN(50,MIN(nx,ngamma))*MAX(nx,ngamma));
  indx = (int*) mxCalloc(nx+1,sizeof(int));

  /* find */
  for (ix=0;ix<nx;ix++){
    indx[ix] = ind.used;
    SO3Grid_dist_region(&SO3G, xalpha[ix], xbeta[ix], xgamma[ix], 
			epsilon, &ind, &dist);
  }
  indx[nx] = ind.used;

  /*printf("found: %d - ",ind.used);
    print_int(ind.data,ind.used);*/
  
  /* generate sparse output matrix */
  plhs[0] = mxCreateSparse(ngamma,nx,1+indx[nx],0);

  /*mxSetPr(plhs[1], dist.data);*/

  pr = mxGetPr(plhs[0]);
  memcpy(pr,dist.data,indx[nx]*sizeof(double));
  irs = mxGetIr(plhs[0]); /* rows  - y */
  jcs = mxGetJc(plhs[0]); /* columns - x */

  for (ix=0;ix<indx[nx];ix++){
    irs[ix] = ind.data[ix];
  }
  for (ix=0;ix<=nx;ix++){
    jcs[ix] = indx[ix];
  }
  /* free memory */
  mxFree(indx);
  buffer_finalize(&ind);
  /*double_buffer_finalize(&dist);*/
  SO3Grid_finalize(&SO3G);

}
