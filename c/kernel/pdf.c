#include <helper.h>

#include <nfft3util.h>
#include <nfft3.h>

#include <pdf.h>
/*#include <string.h>*/

void extract_f_hat(nfsft_plan *ths, complex *f1_hat,complex *f2_hat)
{
  int k,n;

  for (k = 0; k <= ths->N; k++)
    for (n = -k; n <= k; n++)
      f1_hat[SQR(k)+n+k] 
	= f2_hat[NFSFT_INDEX(k,n,ths)];    
}

void set_f_hat(nfsft_plan *ths, complex *f1_hat, complex *f2_hat){

  int k,n;
    
  for (k = 0; k <= ths->N; k++)
    for (n = -k; n <= k; n++)
      f1_hat[NFSFT_INDEX(k,n,ths)] = 
	f2_hat[SQR(k)+n+k];
}


void pdf_init(pdf_plan *ths){
  pdf_init_advanced(ths,0U);
}


void pdf_init_advanced(pdf_plan *ths,unsigned int flags)
{
  unsigned int nfsft_flags = NFSFT_MALLOC_F | NFSFT_MALLOC_F_HAT;
  unsigned int nfft_flags = ((ths->lA>312)?(0U):(PRE_PHI_HUT | PRE_PSI)) | 
    FFTW_INIT | FFT_OUT_OF_PLACE;
    /*NFSFT_NORMALIZED | NFSFT_PRESERVE_F_HAT */
    /*| NFSFT_ZERO_F_HAT*/

  ths->flags = flags;

  /* enable threads*/
  /*fftw_init_threads();
    fftw_plan_with_nthreads(2);*/

  /* initialise NFSFT */
  nfsft_precompute(ths->lA,1000000,0U,0U);
  
  /* c_buffer <-> P_hat */
  if (!(ths->flags & NO_TRAFO_GH)){
    ths->plan_gh.x = ths->gh;
    
    nfsft_init_guru(&ths->plan_gh,ths->lA,ths->lgh,
		    nfsft_flags,nfft_flags,6);
    nfsft_precompute_x(&ths->plan_gh);
    ths->c         = ths->plan_gh.f;
    ths->P_hat     = ths->plan_gh.f_hat;

    nfsft_flags = nfsft_flags & (~NFSFT_MALLOC_F_HAT);
  }
  
  /* P <-> P_hat */
  if (!(ths->flags & NO_TRAFO_R)){
    ths->plan_r.x     = ths->r;
    ths->plan_r.f_hat = ths->P_hat; 
    nfsft_init_guru(&ths->plan_r,ths->lA,ths->lr,NFSFT_MALLOC_F,nfft_flags,6);
    nfsft_precompute_x(&ths->plan_r);
    ths->P_hat = ths->plan_r.f_hat;
    ths->P     = ths->plan_r.f;
  }
}


void pdf_fourier(pdf_plan *ths, double *c)           /* c -> P_hat */
{  
  int i,n,k; 
  
  /* set c_buffer */
  for (i=0;i<ths->lgh;i++)
    ths->c[i] = (complex) c[i % ths->lc] * ths->refl[i / ths->lc];
  
  /******** compute adjoint NSFST *********/
   nfsft_adjoint(&ths->plan_gh);                       /* c -> P_hat */
  
  /****** multiply with kernel coefficients *********/
  for (k= 0; k <= ths->lA; k++)  
    for (n=-k; n <= k; n++)    
      ths->P_hat[NFSFT_INDEX(k,n,&ths->plan_gh)] *= ths->A[k];
}


void pdf_fourier_adjoint(pdf_plan *ths, double *c)    /* P_hat -> c */ 
{
  int n,k,i;

  memset_double(c,0.0,ths->lc);

  /****** multiply with kernel coefficients *********/
  for (k= 0; k <= ths->lA; k++)  {
    for (n=-k; n <= k; n++)   
      ths->P_hat[NFSFT_INDEX(k,n,&ths->plan_gh)] *= ths->A[k];  
  }
  /****** compute NFSFT *********/
  nfsft_trafo(&ths->plan_gh);                         /* P_hat -> c */ 

  /* extract coefficients */
  for (i=0;i<ths->lgh;i++)
    c[i % ths->lc] += creal(ths->c[i]) * ths->refl[i / ths->lc];
}


void pdf_eval(pdf_plan *ths, double *P)               /* P_hat -> P */
{
  int i;
   /******** compute NSFST *********/
  nfsft_trafo(&ths->plan_r);                          /* P_hat -> P */
  
  for (i=0;i<ths->lr;i++) P[i] = creal(ths->P[i]);  
}
 

void pdf_eval_adjoint(pdf_plan *ths, double *P)       /* P -> P_hat */
{  
  int i;
  for (i=0;i<ths->lr;i++) ths->P[i] = (complex) P[i];  
  
  /******** compute adjoint NSFST *********/    
  nfsft_adjoint(&ths->plan_r);                        /* P -> P_hat */ 
}

void pdf_trafo(pdf_plan *ths, double *c, double *P)
{ 
  if (ths->flags & NO_TRAFO_GH)
    set_f_hat(&ths->plan_r,ths->P_hat,(complex*) c);
  else
    pdf_fourier(ths,c);


  if (ths->flags & NO_TRAFO_R)
    extract_f_hat(&ths->plan_gh,(complex*) P,ths->P_hat);
  else
    pdf_eval(ths,P);
}

void pdf_adjoint(pdf_plan *ths, double *P, double *c)
{
  if (ths->flags & NO_TRAFO_R)
    set_f_hat(&ths->plan_gh,ths->P_hat,(complex*) P);
  else
    pdf_eval_adjoint(ths,P);   

  if (ths->flags & NO_TRAFO_GH)
    extract_f_hat(&ths->plan_r,(complex*) c,ths->P_hat);
  else
    pdf_fourier_adjoint(ths,c);
}

void pdf_adjoint_weights(pdf_plan *ths, double *P, double *w, double *c)
{
  int i;
  for (i=0;i<ths->lr;i++) ths->P[i] = (complex) (P[i]*w[i]);  
  
  nfsft_adjoint(&ths->plan_r);                        /* P -> P_hat */ 
  pdf_fourier_adjoint(ths,c);

}

void pdf_finalize(pdf_plan *ths)
{
  if (!(ths->flags & NO_TRAFO_GH)) nfsft_finalize(&ths->plan_gh);
  if (!(ths->flags & NO_TRAFO_R)) nfsft_finalize(&ths->plan_r);
}
