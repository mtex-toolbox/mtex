#include <math.h>
#include <complex.h>
#include <pio.h>
#include <helper.h>

#define Nparam 6

int main(int argc,char *argv[]){

  char f_out_name[BUFSIZ];
  double *A, *gh, *r, *c, *refl;
  int lgh,lr,lc,lA,lh;
  
  

  param_file_type param[Nparam] = 
    {{"gh:" ,"DATA_FILE" ,&gh  ,&lgh ,2*sizeof(double)},
     {"r:"  ,"DATA_FILE" ,&r   ,&lr  ,2*sizeof(double)},
     {"c:"  ,"DATA_FILE" ,&c   ,&lc  ,sizeof(double)},
     {"Al:" ,"DATA_FILE" ,&A   ,&lA  ,sizeof(double)},
     {"refl:","DATA_FILE",&refl,&lh  ,sizeof(double)},
     {"res1:","%s ",&f_out_name,NULL,0}};
    
  FILE *f_param;

  printf("\n ------ MTEX -- read paramater test -------- \n");

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

  printf("\n print A: \n");

  print_double(stdout,A,lA);

  printf("\n");
  
  /* free memory */
  free(gh);
  free(r);
  free(refl);
  free(c);
  
  return(0);
}
