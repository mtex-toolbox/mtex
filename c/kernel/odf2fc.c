#include <math.h>
#include <pio.h>
#include <helper.h>

#include <fc.h>


#define Nparam 4

int main(int argc,char *argv[]){
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

  /* set bandwidth right*/
  L = L - 1; /*! (A(1:end-1)) */

  /* check input data */
  if ((MM == 0) || (M == 0)) {
    printf("Wrong parameters!");
    abort();
  }

  f_hat = (complex*) malloc((1+F_HAT_INDEX(L,L,L))*sizeof(complex));

  perform_o2f(g,MM,c,M,A,L,f_hat);

  f_out = check_fopen(f_out_name,"wb");
  fwrite(f_hat,sizeof(complex),1+F_HAT_INDEX(L,L,L),f_out);
  fclose(f_out);

  /* free memory */

  free(f_hat);


  return(0);
}
