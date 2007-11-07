#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "util.h"
#include "nfft3.h"
#include "api.h"




/**
 * The main program.
 *
 * rechnet beispielhaft eine NFSOFT mit Bandbreite 6 an einem Knotentripel aus
 *
 * \return Exit code
 */


int main ( int argc ,
	   char **argv )
{

  

  nfsoft_plan plan_nfsoft;

  int j,bw,M,k,m;
  double d1,d2,d3;
  double time,error;
  int flags=NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT;


  bw=6;
  M=1;

  k=100000000;
  m=2;

  nfsoft_init_guru(&plan_nfsoft,bw, M ,flags,
		   PRE_PHI_HUT| PRE_PSI| MALLOC_X| MALLOC_F_HAT| MALLOC_F| 
		   FFTW_INIT| FFT_OUT_OF_PLACE,m,k);


	
  /** Read in nodes. */
  for (j = 0; j < plan_nfsoft.M_total; j++)
    {
      d1=((double)rand())/RAND_MAX-0.5;
      d2=0.5*((double)rand())/RAND_MAX;
      d3=((double)rand())/RAND_MAX-0.5;
      
      plan_nfsoft.x[3*j] = 0;  /**alpha*/
      plan_nfsoft.x[3*j+1] = 0.25;  /**beta*/
      plan_nfsoft.x[3*j+2] = 0;    /**gamma*/
    }


  /** init Fourier coefficients and show them */

  for(j=0;j<(bw+1)*(4*(bw+1)*(bw+1)-1)/3;j++)
    {
      d1=((double)rand())/RAND_MAX - 0.5 +  I*(((double)rand())/RAND_MAX - 0.5);
      d2=((double)rand())/RAND_MAX - 0.5 +  I*(((double)rand())/RAND_MAX - 0.5);
      plan_nfsoft.f_hat[j]=d1 +  I*d2;
      plan_ndsoft.f_hat[j]=d1 +  I*d2;
      // fprintf(stdout,"beispielcoeffs=%.16f\n",creal(plan_nfsoft.f_hat[j]));
      // fprintf(stdout,"beispielcoeffs=%.16f\n",creal(plan_nfsoft.f_hat[j]));
    }
	


  time = nfft_second();
  nfsoft_trafo(&plan_nfsoft);
  time = (nfft_second() - time);
  fprintf(stdout," time (fast) = %11le\n",time);



  time = nfft_second();
  nfsoft_trafo(&plan_ndsoft);
  time = (nfft_second() - time);
  fprintf(stdout," time (slow) = %11le\n",time);


 
/**compute the error*/
error=nfft_error_l_infty_complex(plan_ndsoft.f,plan_nfsoft.f, plan_nfsoft.M_total); 
fprintf(stdout,"\n The fast algorithm bw=%d for %d nodes using m=%d has infty-error %11le \n",bw, M, m,error);

nfsoft_finalize(&plan_ndsoft);
nfsoft_finalize(&plan_nfsoft);


  /* Exit the program. */
  return EXIT_SUCCESS;

}
