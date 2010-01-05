/**
 * @file   pf2pdf.c
 * @author ralf
 * @date   Thu Oct 12 07:28:18 2006
 * 
 * @brief  calculates the Fourier coefficients of a pdf
 * 
 * 
 */


#include <math.h>
#include <pio.h>
#include <helper.h>
#include <ipdf.h>
#include <pdf.h>


#define Nparam 7


int main(int argc,char *argv[]){

  ipdf_plan plan;
  char f_out_name[BUFSIZ];
  int lP;
  int bw,lA,lw;
  complex *P_hat;
  double *A,*w;
  short int flags = CGNR;

  param_file_type param[Nparam] = 
    {{"bw:" ,"%d"        ,&bw       ,NULL    ,sizeof(int)},
     {"r:"  ,"DATA_FILE" ,&plan.r   ,&plan.lr,2*sizeof(double)},
     {"P:"  ,"DATA_FILE" ,&plan.P   ,&lP     ,sizeof(double)},
     {"A:"  ,"DATA_FILE" ,&A        ,&lA     ,sizeof(double)},
     {"w:"  ,"DATA_FILE" ,&w        ,&lw     ,sizeof(double)},
     {"iter_max:","%d"   ,&plan.max_iter,NULL,sizeof(int)},
     {"res1:","%s ",&f_out_name,NULL,0}};
    
  FILE *f_param;
  FILE *f_out;

  if (argc<2) {
    printf("Error! Missing parameter - parameter_file.\n");
    printf("%s\n",argv[0]);
    abort();
  }
  
  /* read parameter file */
  f_param = check_fopen(argv[1],"r");
  if (read_param_file(f_param,param,Nparam,argc==2)+2<Nparam){
    printf("Some parameters not found!");
    abort();
  }
  fclose(f_param);

  if (lA != 0){
    if (lA == bw+1)
      flags = flags | PRECOMPUTE_DAMP;
    else {
      printf("wrong number of damps!");
      abort();
    }
  }
  if (lw != 0){
    if (lw == plan.lr)
      flags = flags | PRECOMPUTE_WEIGHT;
    else{
      printf("wrong number of weigths!");
      abort();
    }
  }
  /* check input data */
  if (lP != plan.lr){
    printf("Data inconsitency!");
    abort();
  }

  /* perform pdf inversion*/
  /*vpr_double(plan.P,lP,"ndsft, vector P");*/
  ipdf_init(&plan,bw,A,w,flags);
  ipdf_solve(&plan);

  /*plan.plan.f_hat = plan.iplan.f_hat_iter;
  nfsft_trafo(&plan.plan);
  vpr_complex(plan.plan.f,lP,"ndsft, vector P_rec");*/
  
  /* save results */
  P_hat = (complex*) malloc(SQR(1+bw)*sizeof(complex));
  extract_f_hat(&plan.plan,P_hat,plan.iplan.f_hat_iter);

  f_out = check_fopen(f_out_name,"w");
  fwrite(P_hat,sizeof(complex),SQR(bw+1),f_out);
  fclose(f_out);

  /* free memory */
  if (flags &  PRECOMPUTE_DAMP)free(A);
  if (flags &  PRECOMPUTE_WEIGHT)free(w);
  free(plan.r);
  free(plan.P);
  free(P_hat);
  ipdf_finalize(&plan);
  
  return(0);
}
