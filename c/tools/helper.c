/**
 * @file   helper.c
 * @author ralf
 * @date   Thu Oct 12 07:09:33 2006
 * 
 * @brief  some basic vector operations
 * 
 * 
 */


#include <helper.h>

void print_long(FILE *f,const char *format,long *x,int nx){
  int i;
  
  for (i=0;i<nx;i++){
    fprintf(f,format,x[i]);
  }
}

void print_int(FILE *f,int *x,int nx){
  int i;
  
  for (i=0;i<nx;i++){
    fprintf(f,"%d ",x[i]);
  }
}

void print_double(FILE *f,double *x,int nx){
  int i;

  for (i=0;i<nx;i++){
    fprintf(f,"%.4E ",x[i]);
  }
}

void print_complex(FILE *f,complex *x,int nx){
  int i;
  
  for (i=0;i<nx;i++){
    fprintf(f,"%.4E+%.4Ei ",creal(x[i]),cimag(x[i]));
  }
}

void memset_double(double *x,double dx,int lx)
{
  int i;
  for (i=0;i<lx;i++) x[i] = dx;
}

void memset_complex(complex *x,complex dx,int lx)
{
  int i;
  for (i=0;i<lx;i++) x[i] = dx;
}

void v_memcpy_double2complex(complex *x,double* y,int lx)
{
  int i;
  for (i=0;i<lx;i++) x[i] = (complex) y[i];
}

void v_memcpy_complex2double(double *x,complex* y,int lx)
{
  int i;
  for (i=0;i<lx;i++) x[i] = creal(y[i]);
}

double l2_error(double *x,double *y,int lx){
  int i;
  double q=0;
  
  for (i=0;i<lx;i++) q+=(x[i]-y[i])*(x[i]-y[i]);
  return q;
}

/*void cp_a_double(double *x,double a,double *y,int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] = a*y[i];
}
*/

double v_sum_double(double *x,int lx){
  int i;
  double s;
  for (i=0,s=0;i<lx;i++)
    s+=x[i];
  return(s);
}

void v_add_a_double(double *x,double a,int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] += a;
}

void v_prd_a_double(double *x,double a,int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] = x[i]*a;
}


void v_add_a_x_double(double *x,double a,double *y,int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] += a*y[i];
}

void v_cp_a_x_double(double* x, double a, double* y, int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] = a*y[i];
}


void v_sum_a_x_b_y_double(double *x,double a,double *y,double b,double *z,int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] = a*y[i] + b*z[i];
}

void v_minus_x_y_double(double *z,double *x,double *y,int lx){
  int i;
  for (i=0;i<lx;i++)
    z[i] = x[i]-y[i];
}

void v_prd_x_y_double(double *z,double *x,double *y,int lx){
  int i;
  for (i=0;i<lx;i++)
    z[i] = x[i]*y[i];
}

double v_norm_double(double *x,int lx){
  int i;
  double d;
  d = 0;
  for (i=0;i<lx;i++)
    d += x[i]*x[i];
  return d;
}

double v_norm_w_double(double *x,double *w,int lx){
  int i;
  double d;
  d = 0;
  for (i=0;i<lx;i++)
    d += x[i]*x[i]*w[i];
  return d;
}

double v_norm_ww_double(double *x,double *w,int lx){
  int i;
  double d;
  d = 0;
  for (i=0;i<lx;i++)
    d += x[i]*x[i]*w[i]*w[i];
  return d;
}

double v_dot_double(double *x,double *y,int lx){
  int i;
  double d;
  d = 0;
  for (i=0;i<lx;i++)
    d += x[i]*y[i];
  return d;
}

double v_dot_w_double(double *x,double *y,double *w,int lx){
  int i;
  double d;
  d = 0;
  for (i=0;i<lx;i++)
    d += x[i]*y[i]*w[i];
  return d;
}

void v_odot_x_y_double(double *x,double *y, double *z, int lx){
  int i;
  for (i=0;i<lx;i++)
    x[i] = y[i] * z[i];
} 
