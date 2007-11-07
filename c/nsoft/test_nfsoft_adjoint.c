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
 * rechnet beispielhaft eine NFSOFT mit Bandbreite 6 in einem Knoten aus
 *
 * \return Exit code
 */


int main ( int argc ,
	   char **argv )
{


  nfsoft_plan plan;

  int j,bw,M,m,max_l,l;
  int k,kk,L;
  double d1,d2,d3;
  int flags=NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT;
  
  
  bw=6;
  M=1;


  nfsoft_init_guru(&plan,bw, M ,flags,
		   PRE_PHI_HUT| PRE_PSI| MALLOC_X| MALLOC_F_HAT| MALLOC_F|
		   FFTW_INIT| FFT_OUT_OF_PLACE,6,1000);
 

	
  /** Read in nodes. */
  for (j = 0; j < plan.M_total; j++)
    {
      d1 = 0;
      d2 = 1.5708;
      d3 = 0;
      
      plan.x[3*j] = d1;  /**alpha*/
      plan.x[3*j+1] = d2;  /**beta*/
      plan.x[3*j+2] = d3;    /**gamma*/
      
    }


  /** init function values */
  
  for(j=0;j<M;j++)
    {
      plan.f[j]= 1;
    }


 
  nfsoft_adjoint(&plan);

  /* show results */
  m=0;
  L = bw;
  for (k = -L; k <= L; k++)
    for (kk = -L; kk <= L; kk++) {
      
      max_l=(abs(k)>abs(kk)?abs(k):abs(kk));
      
      for (l = max_l; l <= L; l++) {
	if (l == 1)
	  fprintf(stdout,"l=%d k=%d k'=%d D=%.4e + i*%.4e\n",
		  l,k,kk,creal(plan.f_hat[m]),cimag(plan.f_hat[m]));
	m++;
      }
    } 

  nfsoft_finalize(&plan);

  /* Exit the program. */
  return EXIT_SUCCESS;

}
