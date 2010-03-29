/*#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef _OPENMP
  #include <omp.h>
#endif*/

#include <mpfr.h>
#define MPFR_NEED_LONGLONG_H
#include "mpfr-impl.h"
//#include "gmp.h"

/*
int digits;
long int prec; 
mpfr_t delta, delta2;
*/

void init_prec(int digit);

void print_N(mpfr_t *a, const int n);

void print_Nf(mpfr_t *a, const int n);

void print_NN(mpfr_t **A,const int n);

void free_N(mpfr_t *t, const int n);

void free_NN(mpfr_t **t, const int n);

void mhyper(mpfr_t f, mpfr_t *kappa, const long n);      // eval 1F1

void eval_exp_Ah(mpfr_t C, double *f,int n);  // odf eval

void eval_exp_besseli(double *a,double *bc,mpfr_t C, int n);           // pdf eval

int mpfr_i0(mpfr_t res, mpfr_srcptr z, mp_rnd_t r); //prec

void copy(mpfr_t *out, mpfr_t *in,int n);

void dmhyper(mpfr_t *df, mpfr_t *kappa,int n);

void jmhyper(mpfr_t **jf, mpfr_t *kappa,int n);

int max_N(mpfr_t *z,const int n);

int min_N(mpfr_t *z,const int n);

void check_diag(mpfr_t **A,const int n);

void swap_row_NN(mpfr_t **A, int from, int to ,const int n);

void swap_row_N(mpfr_t *b, int from, int to ,const int n);

void pivot(mpfr_t **A, mpfr_t *b,const int n);

void solveAxb(mpfr_t *x, mpfr_t **A, mpfr_t *b ,int n);

void guessinitial(mpfr_t *kappa, mpfr_t *lambda,const int n);

void newton(int iters, mpfr_t *kappa, mpfr_t *lambda, int n);

