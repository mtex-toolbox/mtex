/**
 * @file   sparse.c
 * @author ralf
 * @date   Thu Oct 12 08:18:43 2006
 * 
 * @brief  sparse matrix handling
 * 
 * 
 */


#include <stdlib.h>
#include <sparse.h>
#include <math.h>
#include <helper.h>


void sparse_init(sparse_matrix *ths,int nrow,int ncol){
  ths->nrow = nrow;
  ths->ncol = ncol;
  ths->nz = ths->jc[ncol];
}

void sparse_finalize(sparse_matrix *ths){
  free(ths->jc);
  free(ths->ir);
  free(ths->pr);
}

void sparse_mul(sparse_matrix *ths,double *vec,double *res){
  int col,row;

  memset_double(res,0.0,ths->nrow);
  for (col = 0;col < ths->ncol;col ++) 
    for (row = ths->jc[col];row < ths->jc[col+1];row++)
      res[ths->ir[row]] += ths->pr[row] * vec[col];     
}

void sparse_mul_transpose(sparse_matrix *ths,double *vec, double *res){
  int col,row;

  memset_double(res,0.0,ths->ncol);
  for (col = 0;col < ths->ncol;col ++) 
    for (row = ths->jc[col];row < ths->jc[col+1];row++)
      res[col] += ths->pr[row] * vec[ths->ir[row]];     
}

void sparse_print(sparse_matrix *ths){
  int col,irow;
  
  for (col = 0;col < 10;col ++) {
    for (irow = ths->jc[col];irow < ths->jc[col+1];irow++){
      fprintf(stderr,"%.4E ",ths->pr[irow]);
    }
    fprintf(stderr," \n");
  }
}

