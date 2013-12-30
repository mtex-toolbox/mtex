#include <complex.h>

#define F_HAT_INDEX(l,k,kk) ((l)*(2*(l)-1)*(2*(l)+1)/3 + (k+l)*(2*(l)+1)+((kk)+l))

void ralf2antje_hat(complex *ralf_hat, complex *antje_hat, int L);

void antje2ralf_hat(complex *ralf_hat, complex *antje_hat,double *A, int L);

void perform_f2o(int L, int M, complex *f_hat, double *g, double *c);

void perform_o2f(double *g,int MM, double *c,int M, double *A,int L, complex *f_hat);