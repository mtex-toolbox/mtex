/**
 * @file   odf.c
 * @author ralf
 * @date   Thu Oct 12 11:27:22 2006
 * 
 * @brief  compares the recalculated ODF against a true given ODF.
 * 
 * 
 */


#include <stdlib.h>
#include <odf.h>
#include <stdio.h>
#include <math.h>
#include <helper.h>


void odf_init(odf_plan *ths){

  ths->lorig = ths->eval_matrix->nrow;
  ths->norm_orig = v_norm_double(ths->orig,ths->lorig);
  ths->rec = (double*) malloc(ths->lorig*sizeof(double));
}

void odf_finalize(odf_plan *ths){

  sparse_finalize(ths->eval_matrix);
  free(ths->rec);
}

double odf_error(odf_plan *ths,double *c){
  int m;
  double e;
  double norm;

  sparse_mul(ths->eval_matrix,c,ths->rec);
  norm = v_sum_double(c,ths->eval_matrix->ncol);
  
  for (m=0,e=0;m<ths->lorig;m++)
    e += ABS(ths->rec[m]/norm - ths->orig[m]);

  return(e/ths->lorig/2);
  /* return(sqrt(l2_error(ths->rec,ths->orig,ths->lorig)/ths->norm_orig)); */
}
