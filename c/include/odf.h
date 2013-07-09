/**
 * @file   odf.h
 * @author ralf
 * @date   Thu Oct 12 11:28:19 2006
 * 
 * @brief  compares the recalculated ODF against a true given ODF.
 * 
 * 
 */

#include <sparse.h>

typedef struct odf_plan_{

  unsigned int flags;

  sparse_matrix *eval_matrix;            /* */

  double *rec;                         /* */
  double *orig;                        /* */
  double norm_orig;
  int    lorig;
  
} odf_plan;


void odf_init(odf_plan *ths);

void odf_finalize(odf_plan *ths);

double odf_error(odf_plan *ths,double *c);

void odf_trafo(odf_plan *ths,double *c);

void odf_print(odf_plan *ths);
