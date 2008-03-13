#include <math.h>
#include <complex.h>
#include <pio.h>
#include <helper.h>
#include <api.h>

#define Nparam 4
#define F_HAT_INDEX(l,k,kk) ((l)*(2*(l)-1)*(2*(l)+1)/3 + (k+l)*(2*(l)+1)+((kk)+l))

void ralf2antje_hat(complex *ralf_hat, complex *antje_hat, int L){

  int l,k,kk,m,max_l;

  m=0;
  for (k = -L; k <= L; k++)
    for (kk = -L; kk <= L; kk++) {
      
      max_l=(abs(k)>abs(kk)?abs(k):abs(kk));
      
      for (l = max_l; l <= L; l++)	{
	antje_hat[m] = ralf_hat[F_HAT_INDEX(l,k,kk)];
	/* printf("%d ",F_HAT_INDEX(l,k,kk));fflush(stdout);*/
	/*	if (l % 2 == 1)*/
	/*printf("%.4E + %.4Ei ",creal(antje_hat[m]),cimag(antje_hat[m]));*/
	m++;
      }
    }
}


int main(int argc,char *argv[]){

  nfsoft_plan plan;
  char f_out_name[BUFSIZ];
  complex *f_hat;
  double *c;
  double *g;
  int L,LL,M,m;

  param_file_type param[Nparam] = 
    {{"L:" ,"%d" ,&L ,NULL ,sizeof(int)},
     {"g:" ,"DATA_FILE" ,&g ,&M ,3*sizeof(double)},
     {"f_hat:" ,"DATA_FILE" ,&f_hat ,&LL,sizeof(complex)},
     {"res1:","%s ",&f_out_name,NULL,0}};
    
  FILE *f_param;
  FILE *f_out;

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

  int NFSOFT_flags= NFSOFT_MALLOC_X | NFSOFT_MALLOC_F | NFSOFT_MALLOC_F_HAT;
  int NFFT_flags = ((L>55)?(0U):(PRE_PHI_HUT | PRE_PSI)) | 
    MALLOC_F_HAT| MALLOC_F | MALLOC_X | FFTW_INIT| FFT_OUT_OF_PLACE;

  /* check input data */
  if ((LL != 1 + F_HAT_INDEX(L,L,L)) || (M == 0)) { 
    printf("Wrong parameters: L1=%d L2=%d",LL,F_HAT_INDEX(L,L,L));
    abort();
  }

  /* initialize plan*/
  nfsoft_init_guru(&plan,L,M,NFSOFT_flags,NFFT_flags,6,1000);

  /* copy Fourier coefficients */
  ralf2antje_hat(f_hat,plan.f_hat,L);

  /* copy nodes */
  for (m=0;m<3*M;m++)
    plan.x[m] = g[m];
  
  /* perform nfsoft_trafo*/ 
  nfsoft_trafo(&plan);
  
  /* save results */
  c = (double*) malloc(M * sizeof(double));
  for (m=0;m<M;m++)
    c[m] = creal(plan.f[m]);

  f_out = check_fopen(f_out_name,"w");
  fwrite(c,sizeof(double),M,f_out);
  fclose(f_out);

  /* free memory */
  free(g);
  free(c);
  free(f_hat);
  nfsoft_finalize(&plan);
  
  return(0);
}
