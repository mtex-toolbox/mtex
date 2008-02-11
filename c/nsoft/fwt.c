/** Include standard C headers, NFFT3 library 
*   header and the custom-made NFSOFT api */
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <util.h>
#include <api.h>




/**
 * The main program.
 *
 * computes a Fast Wigner transform (FWT) by means of the fast polynomial transform (FPT) and
 * a Discrete Wigner transform (DWT) by means of the discrete polynomial transform (DPT),
 * at the desired bandwidth bw at fixed orders m and n, i.e.,
 * the Chebychev coefficients occuring with the change of basis between Wigner-d functions
 * and Chebychev polynomials of first kind
 *
 * \f[
 * \sum^{bw}_{l=0} t^{mn}_l \cos(l beta_q)=\sum^{bw}_{l=0}\hat f^ {mn}_l d_{mn}^l(\beta_q) 
 * \f]
 *
 *
 * \arg bw the bandwidth
 *
 * \return Exit code
 */


int main ( int argc ,
	   char **argv )
{

  
  if (argc < 2)
    {
      fprintf(stdout,"Usage: fwt bw  \n");
      exit(0);
    }

nfsoft_plan plan_nfsoft;  /**< Plan for the FWT (not the optimal way to do it) */
nfsoft_plan plan_ndsoft;  /**< Plan for the DWT (not the optimal way to do it) */

int j;       /** just an index*/
int bw;      /**< The bandwidth bw  */
int M;       /**< The number of nodes M */
int m=0;     /** the first order of the Wigner-d functions*/
int n=0;     /** the second order of the Wigner-d functions*/
double d1,d2,d3;  /** indeces for initializing the Euler angles*/
double error;  /**...self-explainatory*/
int flags=NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT; /**flags for memory allocation \see api.h*/


        /**Read in bandwidth and set the number of nodes*/
        bw=atoi(argv[1]);
        M=1000;

   /** Init two transform plans using the guru interface. The first one uses the slower DPT
   * instead of the FPT as in the second plan. All arrays for input and
   * output variables are allocated by nfsoft_init_guru(). The
   * array of SO(3) Fourier coefficients is preserved during
   * transformations. The two parameters controlling the accuracy of the NFSOFT are set to
   * k=1000 (FPT kappa) and m=3 (NFFT cut-off parameter)
   * 
   * Note: the NFFT setting are in fact not needed here and only occure due to
   *       suboptimal programming... 
   */
  nfsoft_init_guru(&plan_ndsoft,bw, M,flags | NFSOFT_USE_DPT, 
  PRE_PHI_HUT| PRE_PSI| MALLOC_X| MALLOC_F_HAT| MALLOC_F| FFTW_INIT| FFT_OUT_OF_PLACE,3,1000);

  nfsoft_init_guru(&plan_nfsoft,bw, M ,flags,
  PRE_PHI_HUT| PRE_PSI| MALLOC_X| MALLOC_F_HAT| MALLOC_F| FFTW_INIT| FFT_OUT_OF_PLACE,3,1000);


	
      /** Init random nodes (for both plans, the same). */
      for (j = 0; j < plan_nfsoft.M_total; j++)
      {
        d1=((double)rand())/RAND_MAX-0.5;
	d2=0.5*((double)rand())/RAND_MAX;
	d3=((double)rand())/RAND_MAX-0.5;

	plan_nfsoft.x[3*j] = d1;  /**alpha*/
	plan_nfsoft.x[3*j+1] = d2;  /**beta*/
        plan_nfsoft.x[3*j+2] = d3;    /**gamma*/
	plan_ndsoft.x[3*j] = d1;  /**alpha*/
	plan_ndsoft.x[3*j+1] = d2;  /**beta*/
        plan_ndsoft.x[3*j+2] = d3;    /**gamma*/

      }


	  /** init random SO(3) Fourier coefficients (again the same for both plans) */
	  for(j=0;j<=bw-m;j++)
	  {
	   plan_nfsoft.wig_coeffs[j]=((double)rand())/RAND_MAX - 0.5 +  I*(((double)rand())/RAND_MAX - 0.5);
	   plan_ndsoft.wig_coeffs[j]=plan_nfsoft.wig_coeffs[j];
	  }

	  for(j=bw-m+1;j<nfft_next_power_of_2(bw)+1;j++)
	  {
           plan_nfsoft.wig_coeffs[j]=0.0;
	   plan_ndsoft.wig_coeffs[j]=0.0;
	  }



/** Compute the fast and direct transformation */
SO3_fpt(plan_nfsoft.wig_coeffs,bw,m,n,plan_nfsoft.flags,1000); 
SO3_fpt(plan_ndsoft.wig_coeffs,bw,m,n,plan_ndsoft.flags,1000); 



/**compute the error between the DWT (DPT) and FWT (FPT) and display it*/
error=nfft_error_l_infty_complex(plan_ndsoft.wig_coeffs,plan_nfsoft.wig_coeffs, bw+1); 
fprintf(stdout,"\n The fast algorithm bw=%d  using kappa=%d has infty-error %11le \n",bw, 1000,error);


/**destroy the plans*/
nfsoft_finalize(&plan_ndsoft);
nfsoft_finalize(&plan_nfsoft);


  /* Exit the program. */
  return EXIT_SUCCESS;

}






