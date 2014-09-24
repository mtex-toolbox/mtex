
#include <helper.h>
#include <ipdf.h>
#include <math.h>

/*#include <complex.h>*/
/*#include <fftw3.h>*/


void ipdf_init(ipdf_plan *ths,int lA, double *A,double *w, short int flags){
  int j,k,n;                      /**< index for nodes and freqencies  */
  
  /* initialise NFSFT */
  nfsft_precompute(lA,1000000,0U,0U);
  
  /** init two dimensional NFFT plan */
  ths->plan.x     = ths->r;
  nfsft_init_advanced(&ths->plan,lA,ths->lr,
		  NFSFT_MALLOC_F | NFSFT_MALLOC_F_HAT | NFSFT_ZERO_F_HAT);
 
    
  /** init two dimensional infsft plan */
  solver_init_advanced_complex(&ths->iplan,(mv_plan_complex*)(&ths->plan), flags);

  /* init damps */
  if (flags &  PRECOMPUTE_DAMP)
    for (k = 0; k <= lA; k++)
      for (n = -k; n <= k; n++)
	ths->iplan.w_hat[NFSFT_INDEX(k,n,&ths->plan)] = A[k];

  /* init weights */
  if (flags &  PRECOMPUTE_WEIGHT)
    for (j=0;j<=ths->lr;j++)
      ths->iplan.w[j] = w[j];
  
  /** init nodes and weights of grid*/
  /*  for(j=0;j<ths->plan.M_total;j++)
      ths->iplan.w[j] = 1.0;*/

  /* set y - vector */
  int i;
  for (i=0;i< ths->lr ;i++) ths->iplan.y[i] =  (complex) ths->P[i];
  
  
  /*v_memcpy_double2complex(ths->iplan.y,ths->P,ths->lr);*/
  
  /* initialise some guess f_hat_0 */
  for(k=0;k<ths->plan.N_total;k++)
    ths->iplan.f_hat_iter[k] = (complex) 0.0; /*+ I*0.0;*/

}

void ipdf_solve(ipdf_plan *ths){

  int l;
  double error;

  /** solve the system */
  solver_before_loop_complex(&ths->iplan);
  /*error = ths->iplan.dot_r_iter;
    printf("%.4E ",error);fflush(stdout);*/

  for(l=1;l<=ths->max_iter;l++) {
    error = ths->iplan.dot_r_iter;
    solver_loop_one_step_complex(&ths->iplan);
   
    printf("%.4E ",error);fflush(stdout);
    /*if (sqrt(my_infsft_plan.dot_r_iter)<=1e-12) break;*/
  }
}

void ipdf_finalize(ipdf_plan *ths){

  /* finalise the plans and free the variables */

  solver_finalize_complex(&ths->iplan);
  nfsft_finalize(&ths->plan);

}
