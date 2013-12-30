/**
 * @file   sparse.h
 * @author ralf
 * @date   Thu Oct 12 08:19:24 2006
 * 
 * @brief  sparse matrix handling
 * 
 * 
 */

#ifndef SPARSE_H
#define SPARSE_H

typedef struct sparse_matrix_{

  unsigned int flags;

  int     ncol;
  int     nrow;
  int     nz;

  int     *jc;        /* colum indicator (length = ncol+1) */
  int     *ir;        /* row of the matrix elements (length = nz) */
  double  *pr;        /* matrix elements (length = nz) */
  
} sparse_matrix;


void sparse_init(sparse_matrix *ths,int ncol,int nrow);

void sparse_finalize(sparse_matrix *ths);

void sparse_mul(sparse_matrix *ths,double *vec,double *res);

void sparse_mul_adjoint(sparse_matrix *ths,double *vec,double *res);

void sparse_print(sparse_matrix *ths);

#endif
