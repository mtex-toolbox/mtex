/**
 * @file   helper.h
 * @author ralf
 * @date   Thu Oct 12 07:10:27 2006
 * 
 * @brief  some basic vector operations
 * 
 * 
 */


#include <stdio.h>
#include <complex.h>
#define SQR(x) ((x)*(x))
#define ABS(x) (((x) >= 0) ? (x) : -(x))
#define MIN(a,b) (((a) >= (b)) ? (b) : (a))

void memset_double(double *x,double dx,int lx);

void memset_complex(complex *x,complex dx,int lx);

void v_memcpy_double2complex(complex *x,double* y,int lx);

void v_memcpy_complex2double(double *x,complex* y,int lx);

void print_long(FILE *f,const char *format,long *x,int nx);

void print_int(FILE *f,int *x,int nx);

void print_double(FILE *f,double *x,int nx);

void print_complex(FILE *f,complex *x,int nx);

double l2_error(double *x,double *y,int lx);

double v_sum_double(double *x,int lx);

void v_add_a_double(double *x,double a,int lx);

void v_add_a_x_double(double *x,double a,double* y,int lx);

void v_sum_a_x_b_y_double(double *x,double a,double *y,double b,double *z,int lx);

void v_prd_a_double(double *x,double a,int lx);

void v_cp_a_x_double(double* x, double a, double* y, int lx);

void v_minus_x_y_double(double *z,double *x,double *y,int lx);

double v_norm_double(double *x,int lx);

void v_prd_x_y_double(double *z,double *x,double *y,int lx);

double v_norm_w_double(double *x,double *w,int lx);

double v_norm_ww_double(double *x,double *w,int lx);

double v_dot_double(double *x,double *y,int lx);

double v_dot_w_double(double *x,double *y,double *w,int lx);

void v_odot_x_y_double(double *x,double *y, double *z, int lx);
