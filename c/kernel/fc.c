#include <fc.h>
#include <stdlib.h>

#include <nfft3util.h>
#include <nfft3.h>



void ralf2antje_hat(complex *ralf_hat, complex *antje_hat, int L){

  int l,k,kk,m,max_l;

  m=0;
  for (k = -L; k <= L; k++)
    for (kk = -L; kk <= L; kk++) {

      max_l=(abs(k)>abs(kk)?abs(k):abs(kk));

      for (l = max_l; l <= L; l++)	{
	antje_hat[m] = ralf_hat[F_HAT_INDEX(l,k,kk)];
	 /*printf("%d ",F_HAT_INDEX(l,k,kk));fflush(stdout);
		if (l % 2 == 1)
	printf("%.4E + %.4Ei ",creal(antje_hat[m]),cimag(antje_hat[m]));*/
	m++;
      }
    }
}

void antje2ralf_hat(complex *ralf_hat, complex *antje_hat,double *A, int L){

  int l,k,kk,m,max_l;

  m=0;
  for (k = -L; k <= L; k++)
    for (kk = -L; kk <= L; kk++) {
      max_l=(abs(k)>abs(kk)?abs(k):abs(kk));

      for (l = max_l; l <= L; l++) {
	ralf_hat[F_HAT_INDEX(l,k,kk)] = (complex) A[l] * antje_hat[m];
	/*	if (l == 1)*/
	/*fprintf(stdout,"l=%d k=%d k'=%d D=%.4e + i*%.4e\n",*/
	/*l,k,kk,creal(plan.f_hat[m]),cimag(plan.f_hat[m]));*/
	m++;
      }
    }
}



void perform_f2o(int L,int M,complex *f_hat, double *g, double *c){

  nfsoft_plan plan;

  int NFSOFT_flags= NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT | NFSOFT_REPRESENT;
  int NFFT_flags = ((L>55)?(0U):(PRE_PHI_HUT | PRE_PSI)) |
    MALLOC_F_HAT| MALLOC_F | MALLOC_X | FFTW_INIT| FFT_OUT_OF_PLACE;

  int m;

  /* initialize plan*/
  nfsoft_init_guru(&plan,L,M,NFSOFT_flags,NFFT_flags,6,1000);

  /* copy Fourier coefficients */
  ralf2antje_hat(f_hat,plan.f_hat,L);

  /* copy nodes */
  for (m=0;m<3*M;m++)
    plan.x[m] = g[m];

  /* perform nfsoft_trafo*/
  nfsoft_precompute(&plan);
  nfsoft_trafo(&plan);

  /* save results */

  for (m=0;m<M;m++)
    c[m] = creal(plan.f[m]);

  free(g);
  free(f_hat);
  nfsoft_finalize(&plan);
}

void perform_o2f(double *g,int MM, double *c,int M, double *A,int L, complex *f_hat){

  nfsoft_plan plan;

  int flags= NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT | NFSOFT_REPRESENT ;
  int m;

  /* initialize plan*/
  nfsoft_init_advanced(&plan,L, MM ,flags);

  /* copy input coefficients */
  for (m=0;m<MM;m++)
    plan.f[m] = (complex) c[m % M];

  /* copy nodes */
  for (m=0;m<3*MM;m++)
   plan.x[m] = g[m];

  /* perform nfsoft_trafo*/
  nfsoft_precompute(&plan);
  nfsoft_adjoint(&plan);

  /* save results */
  antje2ralf_hat(f_hat,plan.f_hat,A,L);


  free(g);
  free(c);
  free(A);
  nfsoft_finalize(&plan);
}
