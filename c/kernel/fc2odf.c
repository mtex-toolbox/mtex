
#include <pio.h>
#include <fc.h>

#define Nparam 4


int main(int argc,char *argv[]){
  char f_out_name[BUFSIZ];
  complex *f_hat;
  double *c;
  double *g;
  int L,LL,M;

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

  /* check input data */
  if ((LL != 1 + F_HAT_INDEX(L,L,L)) || (M == 0)) {
    printf("Wrong parameters: L1=%d L2=%d",LL,F_HAT_INDEX(L,L,L));
    abort();
  }

  c = (double*) malloc(M * sizeof(double));
  perform_f2o(L,M,f_hat,g,c);

  f_out = check_fopen(f_out_name,"wb");
  fwrite(c,sizeof(double),M,f_out);
  fclose(f_out);

  /* free memory */

  free(c);

  return(0);
}
