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
mpf_t delta, delta2;
*/

void init_prec(int digit);

void print_N(mpf_t *a, const int n);

void print_Nf(mpf_t *a, const int n);

void print_NN(mpf_t **A,const int n);

void free_N(mpf_t *t, const int n);

void free_NN(mpf_t **t, const int n);

void mhyper(mpf_t f, mpf_t *kappa,long n);      // eval 1F1

void mpf_log(mpf_t out, mpf_t in);

void eval_exp_Ah(mpf_t C, double *f, int n);  // odf eval

void eval_exp_besseli(double *a,double *bc,mpf_t C, int n);           // pdf eval

int mpfr_i0(mpfr_t res, mpfr_srcptr z, mp_rnd_t r); //prec

void copy(mpf_t *out, mpf_t *in,int n);

void dmhyper(mpf_t *df, mpf_t *kappa,int n);

void jmhyper(mpf_t **jf, mpf_t *kappa,int n);

int max_N(mpf_t *z,const int n);

int min_N(mpf_t *z,const int n);

void check_diag(mpf_t **A,const int n);

void swap_row_NN(mpf_t **A, int from, int to ,const int n);

void swap_row_N(mpf_t *b, int from, int to ,const int n);

void pivot(mpf_t **A, mpf_t *b,const int n);

void solveAxb(mpf_t *x, mpf_t **A, mpf_t *b ,int n);

void guessinitial(mpf_t *kappa, mpf_t *lambda,const int n);

void newton(int iters, mpf_t *kappa, mpf_t *lambda, int n);

