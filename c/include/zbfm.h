#include <complex.h>
#include <pdf.h>
#include <sparse.h>

#define WEIGHTS                 (1U<< 0)
#define REGULARISATION          (1U<< 1)


typedef struct zbfm_plan_{
 
  unsigned flags;			/**< iteration type, damping, weights */

  /* fiels to save pole figure data  */

  double *P;                            /* Pole figure intensities */
  int    lP;                            /* number of Pole figure intensities */
  int    NP;                            /* Number of Pole figures */
  

  /* fields to save ansatz functions */

  pdf_plan *pdf;                        /* plans to calculate the pole figures */
  int    lc;                            /* number of ansatz functions */

  /* additional parematers */

  double *w;                            /* weighting factors */
  sparse_matrix *reg_matrix;            /* regularization matrix */
  double P_norm;                        /* weighted l2-norm of the input data */

  /* fields to save current approximation*/

  double *c_iter;                       /* curent estimate of the coefficients */
  double *alpha_iter;                   /* scaling coeff of pole figures
					   length(alpha) = NP */
  double *talpha_iter;                  /* scaling coeff of pole figures
					   length(alpha) = NP */
  double error;


  /* buffers for computation*/  
  double *u_iter;
  double *tu_iter;
  double *v_iter;
  double *tc_iter;
  double *c_temp;

  double *a;                            /* for the computation of alpha */
  
  double *A,*B,*C;                      /* for the line search */
  
} zbfm_plan;


/** initialisation for inverse transform, simple interface
 */
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
	       int flags);


/*** implements res = M' * d   ***/
void zbfm_mvt(zbfm_plan *ths,    /* PLAN   */
	      double *d,         /* INPUT  */
	      double *alpha,     /* scaling coefficients*/
	      double *res        /* OUTPUT */
	      );
/*** imlpements M*c   ***/
void zbfm_mv(zbfm_plan *ths, /* PLAN   */
	     double *c,      /* INPUT  */
	     double *alpha,     /* scaling coefficients*/
	     double *res     /* OUTPUT */
	     );

double calculate_RP(zbfm_plan *ths);

void zbfm_before_loop(zbfm_plan *ths);

void zbfm_one_step(zbfm_plan *ths);

void zbfm_finalize(zbfm_plan *ths);
