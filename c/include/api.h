/** 
 * \file api.h
 * \brief Header file with internal API of the NFSOFT module
 * \author Antje Vollrath
 */

#ifndef API_H
#define API_H


/**two default parameters regulating the accuracy */
#define DEFAULT_NFFT_CUTOFF    6
#define FPT_THRESHOLD          1000 

#include <nfft3.h>
#include <fftw3.h>

/* PLANNER FLAGS */
/**
 * By default, all computations are performed with respect to the
 * unnormalized basis functions
 * \f[
 *   D_{mn}^l(\alpha,\beta,\gamma) = d^{mn}_{l}(\cos\beta)
 *   \mathrm{e}^{-\mathrm{i} m \alpha}\mathrm{e}^{-\mathrm{i} n \gamma}.
 * \f]
 * If this flag is set, all computations are carried out using the \f$L_2\f$-
 * normalized basis functions
 * \f[
 *  \tilde D_{mn}^l(\alpha,\beta,\gamma) = \sqrt{\frac{2l+1}{8\pi^2}}d^{mn}_{l}(\cos\beta)
 *   \mathrm{e}^{-\mathrm{i} m \alpha}\mathrm{e}^{-\mathrm{i} n \gamma} 
 * \f]
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_NORMALIZED    (1U << 0)

/**
 * If this flag is set, the fast NFSOFT algorithms (see \ref nfsoft_trafo,
 * \ref nfsoft_adjoint) will use internally the exact but usually slower direct
 * NDFT algorithm in favor of fast but approximative NFFT algorithm.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_USE_NDFT      (1U << 1)

/**
 * If this flag is set, the fast NFSOFT algorithms (see \ref nfsoft_trafo,
 * \ref nfsoft_adjoint) will use internally the usually slower direct
 * DPT algorithm in favor of the fast FPT algorithm.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_USE_DPT       (1U << 2)

/**
 * If this flag is set, the init methods (see \ref nfsoft_init , 
 * \ref nfsoft_init_advanced , and \ref nfsoft_init_guru) will allocate memory and the
 * method \ref nfsoft_finalize will free the array \c x for you. Otherwise,
 * you have to assure by yourself that \c x points to an array of
 * proper size before excuting a transform and you are responsible for freeing
 * the corresponding memory before program termination.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_MALLOC_X      (1U << 3)

/**
 * If this flag is set, the init methods (see \ref nfsoft_init , 
 * \ref nfsoft_init_advanced , and \ref nfsoft_init_guru) will allocate memory and the
 * method \ref nfsoft_finalize will free the array \c f_hat for you. Otherwise,
 * you have to assure by yourself that \c f_hat points to an array of
 * proper size before excuting a transform and you are responsible for freeing
 * the corresponding memory before program termination.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_MALLOC_F_HAT  (1U << 5)

/**
 * If this flag is set, the init methods (see \ref nfsoft_init , 
 * \ref nfsoft_init_advanced , and \ref nfsoft_init_guru) will allocate memory and the
 * method \ref nfsoft_finalize will free the array \c f for you. Otherwise,
 * you have to assure by yourself that \c f points to an array of
 * proper size before excuting a transform and you are responsible for freeing
 * the corresponding memory before program termination.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_MALLOC_F      (1U << 6)

/**
 * If this flag is set, it is guaranteed that during an execution of
 * \ref nfsoft_trafo the content of \c f_hat remains
 * unchanged.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_PRESERVE_F_HAT (1U << 7)

/**
 * If this flag is set, it is guaranteed that during an execution of
 * \ref nfsoft_trafo or \ref nfsoft_adjoint
 * the content of \c x remains
 * unchanged.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_PRESERVE_X     (1U << 8)

/**
 * If this flag is set, it is guaranteed that during an execution of
 * \ref ndsoft_adjoint or \ref nfsoft_adjoint the content of \c f remains
 * unchanged.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_PRESERVE_F     (1U << 9)

/**
 * If this flag is set, it is explicitely allowed that during an execution of
 * \ref nfsoft_trafo the content of \c f_hat may be changed.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_DESTROY_F_HAT    (1U << 10)

/**
 * If this flag is set, it is explicitely allowed that during an execution of
 * \ref nfsoft_trafo or \ref nfsoft_adjoint
 * the content of \c x may be changed.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_DESTROY_X      (1U << 11)

/**
 * If this flag is set, it is explicitely allowed that during an execution of
 * \ref ndsoft_adjoint or \ref nfsoft_adjoint the content of \c f may be changed.
 *
 * \see nfsoft_init
 * \see nfsoft_init_advanced
 * \see nfsoft_init_guru
 * \author Antje Vollrath
 */
#define NFSOFT_DESTROY_F      (1U << 12)

/**
 * If this flag is set, the transform \ref nfsoft_adjoint 
 * sets all unused entries in \c f_hat not corresponding to
 * SO(3) Fourier coefficients to zero.
 *
 * \author Antje Vollrath
 */
#define NFSOFT_ZERO_F_HAT             (1U << 16)

/* HELPER MACROS */
#define MAX(A,B) (abs(A)>abs(B)?abs(A):abs(B))

/**
 * This helper macro expands to the index \f$i\f$
 * corresponding to the SO(3) Fourier coefficient
 * \f$f_hat^{mn}_l\f$ for \f$l=0,...,B\f$, \f$m,n =-l,...,l\f$ 
 * but within the internal nfft_plans \see NFSOFT_INDEX_TWO
 */

#define NFSOFT_INDEX(m,n,l,B)        (((l)+((B)+1))+(2*(B)+2)*(((n)+((B)+1))+(2*(B)+2)*((m)+((B)+1))))



/**
 * This helper macro expands to the index \f$i\f$
 * corresponding to the SO(3) Fourier coefficient
 * \f$f_hat^{mn}_l\f$ for \f$l=0,...,B\f$, \f$m,n =-l,...,l\f$. 
 * Use it when initializing the NFSOFT_plan or when getting the ready 
 * transformed coefficients after the transform
 */
#define NFSOFT_INDEX_TWO(m,n,l,B) ((B+1)*(B+1)+(B+1)*(B+1)*(m+B)-((m-1)*m*(2*m-1)+(B+1)*(B+2)*(2*B+3))/6)+(posN(n,m,B))+(l-MAX(abs(m),abs(n)))



/**
 * This helper macro expands to the logical size of a SO(3) Fourier coefficients
 * array for a bandwidth B.
 */


#define NFSOFT_F_HAT_SIZE(B)          (((B)+1)*(4*((B)+1)*((B)+1)-1)/3)


int posN(int n,int m, int B);


/** Structure for a NFSOFT transform plan */
typedef struct nfsoft_plan_
{
/** Public members */
int N_total;                           /**< the bandwidth \warning not the number of Fourier coefficients!*/
int M_total;                           /**< total number of samples        */
complex *f_hat;                        /**< Fourier aka Wigner coefficients*/
complex *f;                            /**< the samples                        */
double *x;                           /**< the  input nodes                    */

/**some auxillary memory*/
  complex *wig_coeffs;		       /**< contains a set of SO(3) Fourier coefficients*
                                    for fixed orders m and n*/
  complex *cheby;		       /**< contains a set of Chebychev coefficients for*
                                    fixed orders m and n*/
  complex *aux;			       /**< used when converting Chebychev to Fourier* 
                                    coeffcients*/

  /** Private members */
  int t;                               /**< the logaritm of NPT with           *
                                          respect to the basis 2             */
  unsigned int flags;                  /**< the planner flags                  */
  nfft_plan nfft_plan;                /**< the internal NFFT plan             */

int fpt_kappa; 			      /**a parameter controlling the accuracy of the FPT*/

}nfsoft_plan;



/**
 * Computes a single transposed FPT transform.
 *
 * \arg coeffs the Chebychev coefficientss that should be transformed
 * \arg l the polynomial degree 
 * \arg k the first order
 * \arg m the second order
 * \arg kappa the parameter controlling the accuracy
 * \arg nfsoft_flags
 */
void SO3_fpt_transposed(complex *coeffs,int l, int k, int m,unsigned int nfsoft_flags,int kappa);
/**
 * Computes a single FPT transform.
 *
 * \arg coeffs the SO(3) Fourier coefficients that should be transformed
 * \arg l the polynomial degree 
 * \arg k the first order
 * \arg m the second order
 * \arg kappa the parameter controlling the accuracy
 * \arg nfsoft_flags
 */
void SO3_fpt(complex *coeffs,int l, int k, int m,unsigned int nfsoft_flags,int kappa);


/**
 * Creates a NFSOFT transform plan.
 *
 * \arg plan a pointer to a \ref nfsoft_plan structure
 * \arg N the bandwidth \f$N \in \mathbb{N}_0\f$
 * \arg M the number of nodes \f$M \in \mathbb{N}\f$
 *
 * \author Antje Vollrath
 */
void nfsoft_init(nfsoft_plan *plan, int N, int M);
/**
 * Creates a NFSOFT transform plan.
 *
 * \arg plan a pointer to a \ref nfsoft_plan structure
 * \arg N the bandwidth \f$N \in \mathbb{N}_0\f$
 * \arg M the number of nodes \f$M \in \mathbb{N}\f$
 * \arg nfsoft_flags the NFSOFT flags
 *
 * \author Antje Vollrath
 */
void nfsoft_init_advanced(nfsoft_plan *plan, int N, int M,unsigned int nfsoft_flags);
/**
 * Creates a  NFSOFT transform plan.
 *
 * \arg plan a pointer to a \ref nfsoft_plan structure
 * \arg N the bandwidth \f$N \in \mathbb{N}_0\f$
 * \arg M the number of nodes \f$M \in \mathbb{N}\f$
 * \arg nfsoft_flags the NFSFT flags
 * \arg nfft_flags the NFFT flags
 * \arg fpt_kappa a parameter contolling the accuracy of the FPT
 * \arg nfft_cutoff the NFFT cutoff parameter
 *
 * \author Antje Vollrath
 */
void nfsoft_init_guru(nfsoft_plan *plan, int N, int M,unsigned int nfsoft_flags, int nfft_flags,int nfft_cutoff,int fpt_kappa);

/**
 * Executes a NFSOFT, i.e. computes for \f$m = 0,\ldots,M-1\f$
 * \f[
 *   f(g_m) = \sum_{l=0}^B \sum_{m=-l}^l \sum_{n=-l}^l \hat{f}^{mn}_l 
 *            D_l^{mn}\left( \alpha_m,\beta_m,\gamma_m\right).
 * \f]
 *
 * \arg plan_nfsoft the plan
 *
 * \author Antje Vollrath
 */
void nfsoft_trafo(nfsoft_plan *plan_nfsoft);
/**
 * Executes an adjoint NFSOFT, i.e. computes for \f$l=0,\ldots,B;
 * m,n=-l,\ldots,l\f$
 * \f[
 *   \hat{f}^{mn}_l = \sum_{m = 0}^{M-1} f(g_m) 
 *                    D_l^{mn}\left( \alpha_m,\beta_m,\gamma_m\right)
 * \f]
 *
 * \arg plan_nfsoft the plan
 *
 * \author Antje Vollrath
 */
void nfsoft_adjoint(nfsoft_plan *plan_nfsoft);
/**
 * Destroys a plan.
 *
 * \arg plan the plan to be destroyed
 *
 * \author Antje Vollrath
 */
void nfsoft_finalize(nfsoft_plan *plan);

#endif

