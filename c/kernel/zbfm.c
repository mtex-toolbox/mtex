/**
 * @file   zbfm.c
 * @author ralf
 * @date   Thu Oct 12 07:47:27 2006
 * 
 * @brief  implements steepest descent algorithm for pdf -> odf inversion
 * 
 * 
 */


#include <stdlib.h>
#include <helper.h>
#include <string.h>
#include <zbfm.h>
#include <nfft3.h>


/************************** constructor ************************************/
void zbfm_init(zbfm_plan *ths,
			
	       int    NP,        /* number of pole figures */
	       int    *lP,       /* number of nodes per pole figure */
	       double *r,        /* pole figure nodes */
	       
	       int    lA,        /* bandwidth */
	       double *A,        /* fourier coefiecients of the ansatz f.*/
	       
	       int    lc,        /* number of ansatz functions*/
	       int    *lh,       /* number of cryst dir. per pole figure*/
	       double *gh,       /* specimen direction gh */
	       double *refl,     /* reflectivity of the crystal directions */
	       int flags){
  
  int ih,ip,iP,reg_flag;

  /* */
  ths->flags = flags;
  ths->NP = NP;
  ths->lc = lc;
  
  /* initialise pdf_transforms */
  ths->pdf = (pdf_plan*) malloc(sizeof(pdf_plan)*NP);
  ih = 0;
  iP = 0;

  for (ip=0;ip<NP;ip++){  

    ths->pdf[ip].lr  = lP[ip];
    ths->pdf[ip].r   = &r[iP*2];

    iP += ths->pdf[ip].lr;

    ths->pdf[ip].lA  = lA;
    ths->pdf[ip].A   = A;
    ths->pdf[ip].lc  = lc;
    ths->pdf[ip].lh  = lh[ip];
    ths->pdf[ip].lgh = lc*lh[ip];
    ths->pdf[ip].gh  = gh+ih*lc*2/*&gh[ih*lc*2]*/;
    ths->pdf[ip].refl= &refl[ih];
       
    ih += lh[ip];

    pdf_init(&ths->pdf[ip]);
    
  }
  ths->lP = iP;

  if (flags & WEIGHTS)
    ths->P_norm = v_norm_ww_double(ths->P,ths->w,ths->lP);
  else 
    ths->P_norm = v_norm_double(ths->P,ths->lP);


  reg_flag = (flags & REGULARISATION) > 0;
 
  /* allocate buffers */
  ths->u_iter = (double*) malloc((iP + reg_flag * lc) * sizeof(double));
  ths->tu_iter = (double*) malloc((iP + reg_flag * lc) * sizeof(double));
  ths->v_iter = (double*) malloc(lc*sizeof(double));
  ths->tc_iter = (double*) malloc(lc*sizeof(double));
  ths->c_temp = (double*) malloc(lc*sizeof(double)); 
  
  ths->a = (double*) malloc(ths->NP * ths->lc * sizeof(double));

  ths->alpha_iter = (double*) malloc((NP + reg_flag) * sizeof(double));
  ths->talpha_iter = (double*) malloc((NP + reg_flag) * sizeof(double));
  ths->A =  (double*) malloc((NP + reg_flag) * sizeof(double)); 
  ths->B =  (double*) malloc((NP + reg_flag) * sizeof(double)); 
  ths->C =  (double*) malloc((NP + reg_flag) * sizeof(double));     
}


/********************************* destructor *******************************/
void zbfm_finalize(zbfm_plan *ths)
{
  int ip;
  
  /* finalize pdf_plans */
  for (ip=0;ip<ths->NP;ip++)
    pdf_finalize(&ths->pdf[ip]);
  free(ths->pdf);

  if (ths->flags & REGULARISATION)
    sparse_finalize(ths->reg_matrix);
  
  if (ths->flags & WEIGHTS)
    free(ths->w);
  
  /* free buffers */
  free(ths->u_iter);
  free(ths->tu_iter);
  free(ths->v_iter);
  free(ths->tc_iter);
  free(ths->c_temp);

  free(ths->a);

  free(ths->alpha_iter);
  free(ths->talpha_iter);
  free(ths->A);free(ths->B);free(ths->C);
}


/*********** fast matrix vector multiplication ****************/
/***  d_i = alpha_i Psi_i * c   ***/
inline void zbfm_mv(zbfm_plan *ths, /* PLAN   */
	     double *c,      /* INPUT  */
	     double *alpha,  /* scaling coefficients*/
	     double *d       /* OUTPUT */
	     )
{ 
  int ip,iP;
  
  /* pdf_trafo for all pole figures */
  for (ip=0,iP=0;ip<ths->NP;iP+=ths->pdf[ip].lr,ip++) {
    v_cp_a_x_double(ths->c_temp,alpha[ip],c,ths->lc);
    pdf_trafo(&ths->pdf[ip],ths->c_temp,d+iP);
  }
}

/*********** fast adjoint matrix vector multiplication ****************/
/***  c = sum alpha_i Psi_i' * d_i   ***/
void zbfm_mvt(zbfm_plan *ths,    /* PLAN   */
	      double *d,         /* INPUT  */
	      double *alpha,     /* scaling coefficients*/
	      double *c          /* OUTPUT */
	      )
{
  int ip,iP;
  
  memset_double(c,0.0,ths->lc);

  /* pdf_adjoint for all pole figures */
  for (ip=0,iP=0;ip<ths->NP;iP+=ths->pdf[ip].lr,ip++){
    pdf_adjoint(&ths->pdf[ip],d+iP,ths->c_temp);
    v_add_a_x_double(c,alpha[ip],ths->c_temp,ths->lc);
  }
}


/**************************** calculate the RP error *************************/
double calculate_RP(zbfm_plan *ths){
  int j;
  double rp;

  for (j=0,rp = 0;j<ths->lP;j++){
    if (ths->flags & WEIGHTS)
      rp += ABS(ths->u_iter[j]) * ths->w[j];
    else
      rp += ABS(ths->u_iter[j] / (ths->P[j]+0.001));
  }

  return(rp/ths->lP);
}


/********************************  precomputations ****************************/
inline void zbfm_before_loop(zbfm_plan *ths){
  int ip,iP;
  double sI;

  /* step 1 */
  /* not needed */

  /* step 2 */
  memset_double(ths->u_iter,1.0,ths->lP);
  for (ip=0,iP=0;ip<ths->NP;iP+=ths->pdf[ip].lr,ip++) {
    
    /* sI <- I^t 1 */
    sI = v_sum_double(&ths->P[iP],ths->pdf[ip].lr);
    
    /* a_i <- Psi^t 1 / I^t 1 */  
    pdf_adjoint(&ths->pdf[ip],&ths->u_iter[iP],&ths->a[ip*ths->lc]);
    v_prd_a_double(&ths->a[ip*ths->lc],1/sI,ths->lc);    
  }  

  /* step 3 */
  /* alpha_i <- 1/ a^t c */
  for (ip = 0;ip<ths->NP;ip++)
    ths->alpha_iter[ip] = 
      1 / v_dot_double(ths->c_iter,&ths->a[ip*ths->lc],ths->lc);

  if (ths->flags & REGULARISATION)
    ths->alpha_iter[ths->NP] = 1 / v_sum_double(ths->c_iter,ths->lc);

  
  /* step 4 */
  /* u_0 <- alpha_0 Reg c */
  if (ths->flags & REGULARISATION){
    sparse_mul(ths->reg_matrix,ths->c_iter,&ths->u_iter[ths->lP]);
    v_prd_a_double(&ths->u_iter[ths->lP],ths->alpha_iter[ths->NP],ths->lc);
  }
  
  /**** step 5 ****/
  /* u_i <- alpha_i * Psi_i c */
  zbfm_mv(ths,ths->c_iter,ths->alpha_iter,ths->u_iter);  
  
  /* u_i <- u_i - I_i */
  v_minus_x_y_double(ths->u_iter,ths->u_iter,ths->P,ths->lP); 

  /* u_i <- u_i odot w_i */
  if (ths->flags & WEIGHTS)
    v_odot_x_y_double(ths->u_iter,ths->u_iter,ths->w,ths->lP);

  /* error -> ||u||_2^2 / ||P||_2^2 */
  if (ths->flags & REGULARISATION)
    ths->error = v_norm_double(ths->u_iter,ths->lP+ths->lc) / ths->P_norm;
  else
    ths->error = v_norm_double(ths->u_iter,ths->lP) / ths->P_norm;
}


/**********************  negative gradient  *************************/
inline void zbfm_gradient(zbfm_plan *ths){
  int ip,iP;
  double tvc;
  
  /* step 8 */ 
  if (ths->flags & REGULARISATION){

    /* v <- Reg u_0 */
    sparse_mul(ths->reg_matrix,&ths->u_iter[ths->lP],ths->v_iter);

    /* v <- v - ||u_0|| */
    v_add_a_double(ths->v_iter,
		   -v_norm_double(&ths->u_iter[ths->lP],ths->lc),ths->lc);

    /* v <- alpha_0 v */
    v_prd_a_double(ths->v_iter,-ths->alpha_iter[ths->NP],ths->lc);
  } else
    memset_double(ths->v_iter,0.0,ths->lc);

  for (ip=0,iP=0;ip<ths->NP;iP+=ths->pdf[ip].lr,ip++){

    /* line 9 */ 
    /* c_temp <- \Psi_i (u_i odot w_i) */
    if (ths->flags & WEIGHTS)
      pdf_adjoint_weights(&ths->pdf[ip],&ths->u_iter[iP],&ths->w[iP],ths->c_temp);
    else
      pdf_adjoint(&ths->pdf[ip],&ths->u_iter[iP],ths->c_temp);

    /* line 10 */
    /* tvc <- <c_tmp,c> */
    tvc = v_dot_double(ths->c_temp,ths->c_iter,ths->lc);

    /* c_tmp <- c_tmp - alpha_i * tvc * a_i  */
    v_add_a_x_double(ths->c_temp,
		     -ths->alpha_iter[ip]*tvc,&ths->a[ip*ths->lc],ths->lc);
    
    /* g <- g - alpha_i * c_tmp */
    v_add_a_x_double(ths->v_iter,-ths->alpha_iter[ip],ths->c_temp,ths->lc);
  }
}

/*********************** talpha_iter, tu_iter *************************/
inline void zbfm_updates(zbfm_plan *ths){
  int ip;
  
  /* step 12 */
  /* talpha_i <- 1 / a_i^t tc */ 
  for (ip=0;ip<ths->NP;ip++)
      ths->talpha_iter[ip] 
	= 1/v_dot_double(&ths->a[ip*ths->lc],ths->tc_iter,ths->lc);
    
  /* step 13 */
  if (ths->flags & REGULARISATION){
    /* talpha_0 <- 1 / sum(tc) */
    ths->talpha_iter[ths->NP] = 1 / v_sum_double(ths->tc_iter,ths->lc);

    /* tu_0 <- talpha_0 Reg tc*/
    sparse_mul(ths->reg_matrix,ths->tc_iter,&ths->tu_iter[ths->lP]);
    v_prd_a_double(&ths->tu_iter[ths->lP],ths->talpha_iter[ths->NP],ths->lc);
  }

  /* step 14 */
  /* tu_i <- talpha_i Psi_i tc*/
  zbfm_mv(ths,ths->tc_iter,ths->talpha_iter,ths->tu_iter);

  /* tu_i <- tu_i - P */
  v_minus_x_y_double(ths->tu_iter,ths->tu_iter,ths->P,ths->lP);

  /* tu_i <- tu_i odot weights */
  if (ths->flags & WEIGHTS)
    v_odot_x_y_double(ths->tu_iter,ths->tu_iter,ths->w,ths->lP); 
}


/****************** line search *****************/
double zbfm_line_search(zbfm_plan *ths,double tau){
  int ip,iP,iter,ilP;
  double J;
  double oJ;
  int flag_Reg;

  flag_Reg = (ths->flags & REGULARISATION) > 0;
  
  /* precomputation */
  for (ip=0,iP=0,J=0;ip<ths->NP + flag_Reg;iP += ilP,ip++){

    if (ip < ths->NP)
      ilP = ths->pdf[ip].lr;
    else
      ilP = ths->lc;

    ths->A[ip] = SQR(ths->talpha_iter[ip]) * 
      v_norm_double(&ths->u_iter[iP],ilP);
    ths->B[ip] = ths->alpha_iter[ip]*ths->talpha_iter[ip]*
      v_dot_double(&ths->u_iter[iP],&ths->tu_iter[iP],ilP);
    ths->C[ip] = SQR(ths->alpha_iter[ip])* 
      v_norm_double(&ths->tu_iter[iP],ilP);
    
    J += (ths->A[ip] + 2*tau*ths->B[ip] + SQR(tau)*ths->C[ip])
      /SQR(tau * ths->alpha_iter[ip] + ths->talpha_iter[ip]);
  }
  oJ = J;

  for (iter=0;J<=oJ && iter<100;iter++){
    oJ = J;
    tau /= 1.1;
    
    /* new value for J(tau) */
    for (ip=0,J=0;ip<ths->NP + flag_Reg;ip++)
      J += (ths->A[ip] + 2*tau*ths->B[ip]+SQR(tau)*ths->C[ip])
	/SQR(tau * ths->alpha_iter[ip]+ths->talpha_iter[ip]);   
  }

  return(tau*1.1);
}

/****************** update alpha_iter, u_iter **********************/
inline void zbfm_residuum_one_step(zbfm_plan *ths,double tau){
  int ip,iP,flag_Reg,ilP;
  double denom;

  flag_Reg = (ths->flags & REGULARISATION) > 0;

  for (ip=0,iP=0;ip<ths->NP + flag_Reg;iP+=ilP,ip++){

    if (ip < ths->NP)
     ilP = ths->pdf[ip].lr;
    else
      ilP = ths->lc;
          
    /* denom <- tau * alpha_i  + talpha_i */
    denom = tau * ths->alpha_iter[ip] + ths->talpha_iter[ip];
    
    /* step 18 */
    /* u_i <- talpha_i/denom u_i + tau*alpha_i/denom tu_i */
    v_sum_a_x_b_y_double(&ths->u_iter[iP],
			 ths->talpha_iter[ip]/denom,&ths->u_iter[iP],
			 tau*ths->alpha_iter[ip]/denom,&ths->tu_iter[iP],ilP);   

    /* step 19 */
    /* alpha_i <- alpha_i talpha_i / denom */
    ths->alpha_iter[ip] = ths->alpha_iter[ip]*ths->talpha_iter[ip]/denom;
  }
  
  /* error -> ||u||_2^2 / ||P||_2^2 */
  if (ths->flags & REGULARISATION)
    ths->error = v_norm_double(ths->u_iter,ths->lP+ths->lc) / ths->P_norm;
  else
    ths->error = v_norm_double(ths->u_iter,ths->lP) / ths->P_norm;
}

/******************** iterates one step *************************/

void zbfm_one_step(zbfm_plan *ths){
  int i;
  double tau;

  /* step 8 - 10 */
  /* v = neg. gradient: */
  zbfm_gradient(ths);                

  /* step 11 */   
  /* MRNDS specific gradient modification tc = c .* v */
  v_prd_x_y_double(ths->tc_iter,ths->c_iter,ths->v_iter,ths->lc);
  
  /* step 12 - 14 */
  /* updates: talpha, tu */
  zbfm_updates(ths);

  /* step 15 */
  /* maximum stepsize */ 
  for (i=0,tau=1E+100;i<ths->lc;i++)
    if (ths->tc_iter[i]<0) 
      tau = MIN(tau,-ths->c_iter[i]/ths->tc_iter[i]);
    
  /* step 16 */
  /* line search */
  tau = zbfm_line_search(ths,tau);
  
   
  /* step 17 */
  /* update c = c + tau * tc */
  v_add_a_x_double(ths->c_iter,tau,ths->tc_iter,ths->lc);


  /*check for negative values in c due to rounding errors */
  for (i=0;i<ths->lc;i++)
    if (ths->c_iter[i] < 0) {
      /*printf(" neg. value in c_iter[%d]=%.4E \n",i,ths->c_iter[i]);*/
      ths->c_iter[i] = 0;
    }

  /* step 18, 19 */
  /* update residuum and scaling coefficients*/
  zbfm_residuum_one_step(ths,tau);
}

/** @} 
 */ 
