#include <math.h>
#include <complex.h>
#include <pio.h>
#include <pdf.h>
#include <helper.h>

#define Nparam 6

int main(int argc,char *argv[]){

  pdf_plan plan;
  char f_out_name[BUFSIZ];
  double *P;
  double *c;
 
  param_file_type param[Nparam] = 
    {{"gh:" ,"DATA_FILE" ,&plan.gh  ,&plan.lgh ,2*sizeof(double)},
     {"r:"  ,"DATA_FILE" ,&plan.r   ,&plan.lr  ,2*sizeof(double)},
     {"c:"  ,"DATA_FILE" ,&c        ,&plan.lc  ,sizeof(double)},
     {"Al:" ,"DATA_FILE" ,&plan.A   ,&plan.lA  ,sizeof(double)},
     {"refl:","DATA_FILE",&plan.refl,&plan.lh  ,sizeof(double)},
     {"res1:","%s ",&f_out_name,NULL,0}};
    
  FILE *f_param;
  FILE *f_out;
 
  if (argc>2)
    printf("\n ------ MTEX -- ODF to PDF calculation -------- \n");

  if (argc<2) {
    printf("Error! Missing parameter - parameter_file.\n");
    printf("%s\n",argv[0]);
    abort();
  }

  /* read parameter file */
  f_param = check_fopen(argv[1],"r");
  if (read_param_file(f_param,param,Nparam,argc==2)+1<Nparam){
    printf("Some parameters not found!");
    abort();
  }
  fclose(f_param);

  /* check input data */
  if (plan.lh == 0) { /* no refleces are given */
    plan.lh = plan.lgh / plan.lc;
    plan.refl = (double*) malloc(plan.lh*sizeof(double));
    memset_double(plan.refl,1.0,plan.lh);
  }
  P = (double*) malloc(plan.lr*sizeof(double));
  plan.lA--; /*reduce lA*/
  
  /* perform pdf_trafo*/
  pdf_init(&plan);  
  pdf_trafo(&plan,c,P);

   /* save results */
  f_out = check_fopen(f_out_name,"wb");
  fwrite(P,sizeof(double),plan.lr,f_out);
  fclose(f_out);
    
  /* free memory */
  free(plan.gh);
  free(plan.r);
  free(plan.refl);
  free(c);
  free(P);
  pdf_finalize(&plan);
  
  return(0);
}
