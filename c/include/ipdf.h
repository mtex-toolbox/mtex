#include <nfft3util.h>
#include <nfft3.h>


typedef struct ipdf_plan_ {

  unsigned flags;		
 
  double *r;                 /* specimen directions*/
  int    lr;                 /* length(r) */
  double *P;                 /* the pole figure intensities to be interpolated*/

  int    max_iter;           /* maximum iteration count */

  nfsft_plan plan;           /**< plan for the nfsft */
  
  solver_plan_complex iplan;         /**< plan for the inverse nfsft */
  
} ipdf_plan;

void ipdf_init(ipdf_plan *ths,int lA,double *A,double *w, short int flags);

void ipdf_solve(ipdf_plan *ths);

void ipdf_finalize(ipdf_plan *ths);

