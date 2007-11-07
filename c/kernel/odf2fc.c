#include <math.h>
#include <complex.h>
#include <pio.h>
#include <helper.h>
#include <api.h>

#define Nparam 4
#define F_HAT_INDEX(l,k,kk) ((l)*(2*(l)-1)*(2*(l)+1)/3 + ((k)+(l))*(2*(l)+1)+((kk)+(l)))


int main(int argc,char *argv[]){

  nfsoft_plan plan;
  char f_out_name[BUFSIZ];
  complex *f_hat;
  double *c;
  double *g;
  double *A;
  int L,M,MM;

  param_file_type param[Nparam] = 
    {{"g:" ,"DATA_FILE" ,&g ,&MM ,3*sizeof(double)},
     {"c:" ,"DATA_FILE" ,&c ,&M,sizeof(double)},
     {"A:","DATA_FILE" ,&A ,&L ,sizeof(double)},
     {"res1:","%s ",&f_out_name,NULL,0}};
    
  FILE *f_param;
  FILE *f_out;

  int flags= NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT;
  
  int l,k,kk,m,max_l;

  if (argc>2)
    printf("\n ------ MTEX -- ODF - Fourier coefficents calculation -------- \n");

  if (argc<2) {
    printf("Error! Missing parameter - parameter_file.\n");
    printf("%s\n",argv[0]);
    abort();
  }
  
  /* read parameter file */
  f_param = check_fopen(argv[1],"r");
  if (read_param_file(f_param,param,Nparam,argc==2)<Nparam){
    printf("Some parameters not found!");
    abort();
  }
  fclose(f_param);

  /* check input data */
  if ((MM == 0) || (M == 0)) { 
    printf("Wrong parameters!");
    abort();
  }

  /* set bandwidth right*/
  L = L - 1;

  /* initialize plan*/
  nfsoft_init_advanced(&plan,L, MM ,flags);

  /* copy input coefficients */
  for (m=0;m<MM;m++)
    plan.f[m] = (complex) c[m % M];
  
  /* copy nodes */
  for (m=0;m<3*MM;m++)
    plan.x[m] = g[m];
  
    /* perform nfsoft_trafo*/ 
  nfsoft_adjoint(&plan);
  
  /* save results */
  f_hat = (complex*) malloc((1+F_HAT_INDEX(L,L,L))*sizeof(complex));

  m=0;
  for (k = -L; k <= L; k++)
    for (kk = -L; kk <= L; kk++) {
      
      max_l=(abs(k)>abs(kk)?abs(k):abs(kk));
      
      for (l = max_l; l <= L; l++) {
	f_hat[F_HAT_INDEX(l,k,kk)] 
	  = (complex) A[l] * plan.f_hat[m];
	/*	if (l == 1)*/
	/*fprintf(stdout,"l=%d k=%d k'=%d D=%.4e + i*%.4e\n",*/
	/*l,k,kk,creal(plan.f_hat[m]),cimag(plan.f_hat[m]));*/
	m++;
      }
    } 

  f_out = check_fopen(f_out_name,"w");
  fwrite(f_hat,sizeof(complex),1+F_HAT_INDEX(L,L,L),f_out);
  fclose(f_out);

  /* free memory */
  free(g);
  free(c);
  free(A);
  free(f_hat);
  nfsoft_finalize(&plan);
  
  return(0);
}
