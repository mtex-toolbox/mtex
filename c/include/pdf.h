#include <complex.h>

#include <nfft3.h>


#define NO_TRAFO_GH        (1U<< 10)
#define NO_TRAFO_R         (1U<< 11)

typedef struct pdf_plan_ {

  unsigned flags;			/**< */
 
  double *r;                            /* specimen directions*/
  int    lr;                            /* length(r) */

  int    lh;                            /* number if crystal directions */
  double *refl;                         /* reflectivity of cryst. axis;
					   length(refl) = lh*/

  double *gh;                           /* g_m s_j h_i;  i = 0..lh-1 */
  int    lgh;                           /* lgh = lc * lh */

  double *A;                            /* legendre coefficients */
  int    lA;                            /* length(A) */

  int    lc;                            /* number of ansatz functions */

  nfsft_plan plan_r, plan_gh;           /* plans for NFSFT */
  
  complex *c;                           /* buffer for c for direct multipl. */
  complex *P_hat;                       /* buffer for F-coefficients of direct multipl. */
  complex *P;                           /* buffer for M*c for direct multipl. */
    
} pdf_plan;

void set_f_hat(nfsft_plan *ths, complex *f1_hat, complex *f2_hat);

void extract_f_hat(nfsft_plan *ths, complex *f1_hat,complex *f2_hat);

void pdf_init(pdf_plan *ths);

void pdf_init_advanced(pdf_plan *ths,unsigned int flags);

void pdf_fourier(pdf_plan *ths, double *c);

void pdf_fourier_adjoint(pdf_plan *ths, double *c);

void pdf_eval(pdf_plan *ths, double *P);

void pdf_eval_adjoint(pdf_plan *ths, double *P);

void pdf_trafo(pdf_plan *ths, double *c, double *P);

void pdf_adjoint(pdf_plan *ths, double *c, double *P);

void pdf_adjoint_weights(pdf_plan *ths, double *P, double *w, double *c);

void pdf_finalize(pdf_plan *ths);
