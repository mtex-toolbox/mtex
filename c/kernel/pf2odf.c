/** 
 * \file pf2odf.c
 * \brief Main program to call PDF-to-ODF inversion
 * \author Ralf Hielscher
 */

#define Nparam 22  /*number of parameters to be read from the parameter file*/

#include <zbfm_solver.h>
#include <pio.h>
#include <helper.h>


int main(int argc,char *argv[])
{
  zbfm_solver_plan solver;
  zbfm_plan zbfm;
  odf_plan odf;

  int i;
  unsigned int flags;    /* flags */

  int    NP,NP1;         /* number of pole figures */
  int    lP1;            /* number of pole figure intensities */
  int    *lP;            /* number of nodes per pole figure */
  int    lr;             /* numer of specimen directions = sum lP*/
  double *r;             /* specimen directions */

  int    lA;             /* bandwidth */
  double *A;
  double *refl;
  double *refl_ext;

  int    *lh;            /* number of crystal directions per pole figure */
  int    sh;             /* overlapped pole figures */
  int    lSym;           /* number of symmetry elements */
  int    lc,lc1,lc2;         /* number of ansatz functions */
  int    lgh;            /* lgh = lc * sh */
  double *gh;

  sparse_matrix reg_matrix;  /* regularization */
  int lreg1, lreg2;          /* number of non zero elements in rec_matrix  */
  
  sparse_matrix eval_matrix; /* error checking */
  int lorig;                 /* length of the orig data */
  int lsparse1,lsparse2;     /* number of non zero elements in eval_matrix  */


  char f_out_name1[BUFSIZ] = "";
  char f_out_name2[BUFSIZ] = "";

  param_file_type param[Nparam] = 
    {{"flags:","%d",&flags,NULL,sizeof(unsigned int)},

     {"lP:","%d",&lP,&NP1,sizeof(int)},
     {"r:","DATA_FILE",&r,&lr,2*sizeof(double)},
     {"P:","DATA_FILE",&zbfm.P,&zbfm.lP,sizeof(double)},

     {"lh:","%d",&lh,&NP,sizeof(int)}, 
     {"refl:","%lE",&refl,&sh,sizeof(double)},

     {"gh:","DATA_FILE",&gh,&lgh,2*sizeof(double)},
     {"c0:","DATA_FILE",&zbfm.c_iter,&lc,sizeof(double)},

     {"A:","DATA_FILE",&A,&lA,sizeof(double)},
     {"w:","DATA_FILE",&zbfm.w,&lP1,sizeof(double)},

     {"iter_max:","%d",&solver.iter_max,NULL,sizeof(int)},
     {"iter_min:","%d",&solver.iter_min,NULL,sizeof(int)},
     {"descent_min:","%lE",&solver.descent_min,NULL,sizeof(double)},

     {"RM_jc:","DATA_FILE",&reg_matrix.jc,&lc1,sizeof(int)},
     {"RM_ir:","DATA_FILE",&reg_matrix.ir,&lreg1,sizeof(int)},
     {"RM_pr:","DATA_FILE",&reg_matrix.pr,&lreg2,sizeof(double)},
     
     {"evaldata:","DATA_FILE",&odf.orig,&lorig,sizeof(double)},
     {"evalmatrix_jc:","DATA_FILE",&eval_matrix.jc,&lc2,sizeof(int)},
     {"evalmatrix_ir:","DATA_FILE",&eval_matrix.ir,&lsparse1,sizeof(int)},
     {"evalmatrix_pr:","DATA_FILE",&eval_matrix.pr,&lsparse2,sizeof(double)},
    
     {"res1:","%s ",f_out_name1,NULL,0},
     {"res2:","%s ",f_out_name2,NULL,0}
    };

  FILE *f_param;
  FILE *f_out; 

  /*printf("\n ------ MTEX -- PDF to ODF Inversion -------- \n");*/

  /* set defaults */

  flags = 0;
  solver.iter_max = 20;
  solver.iter_min = 5;
  solver.descent_min = 0.1;

  /******************** read parameters ***************************/
  if (argc<2) {
    fprintf(stderr,"Error! Missing parameter - parameter_file.\n");
    abort();
  }
   
  f_param = check_fopen(argv[1],"r");
  read_param_file(f_param,param,Nparam,argc==2);
  fclose(f_param);

  /* check data consitency */
  if (flags & WEIGHTS && lP1!=zbfm.lP){
    fprintf(stderr,"wrong number of weighting coefficients.\n");
    abort();
  }

  if (lc <=0 || lA <= 0 || lgh <= 0){
    fprintf(stderr,"wrong parameters! (%d %d)\n",NP,NP1);
    abort();
  }
  
  /* evolve reflection intensities */
  refl_ext = (double*) malloc(lgh/lc * sizeof(double));
  if (sh == 0)
    memset_double(refl_ext,1.0,lgh/lc);
  else {
    lSym = lgh/lc/sh;
    for (i=0;i<sh;i++)
      memset_double(&refl_ext[i*lSym],refl[i]/lSym,lSym);   
  }

  /********************* init solver ********************************/
  fprintf(stdout,"initialize solver\n");fflush(stdout);
  zbfm_init(&zbfm,NP,lP,r,lA-1,A,lc,lh,gh,refl_ext,flags);
  zbfm_solver_init(&solver,&zbfm,flags,f_out_name1);

  /***************************** REGULARISATION ***************************/
  if (flags & REGULARISATION){
    
    if (lc != lc1-1 || lreg1 != lreg2 || reg_matrix.jc[lc] != lreg2){
      fprintf(stderr,"wrong parameters in regularization matrix!\n");
      fprintf(stderr,"lc=%d lc1=%d lreg1=%d lreg2=%d jc[lc]=%d",
	   lc,lc1,lreg1,lreg2,reg_matrix.jc[lc]);
      abort();
    } 
    sparse_init(&reg_matrix,lc,lc);
    zbfm.reg_matrix = &reg_matrix;
  }

  /***************************** ODF TEST ***************************/
  if (flags & ODF_TEST){
    
    if (lc != lc2-1 || lsparse1 != lsparse2 || eval_matrix.jc[lc] != lsparse2){
      fprintf(stderr,"wrong parameters in eval matrx!\n");
      abort();
    } 
    sparse_init(&eval_matrix,lorig,lc);
    odf.eval_matrix = &eval_matrix;
    odf_init(&odf);
    solver.odf = &odf;
    /* odf_print(&odf); */
  }

  /* iterate */
  zbfm_solver_iterate(&solver);


  /* save results */
  if (strlen(f_out_name1)>0){
    f_out = check_fopen(f_out_name1,"wb");
    fwrite(zbfm.c_iter,sizeof(double),zbfm.lc,f_out);
    fclose(f_out);
  }
  if (strlen(f_out_name2)>0){
    f_out = check_fopen(f_out_name2,"wb");
    fwrite(zbfm.alpha_iter,sizeof(double),zbfm.NP,f_out);
    fclose(f_out);
  }

 
  /************************** finalize ******************************/

  /* free plan */
  zbfm_finalize(&zbfm);
  zbfm_solver_finalize(&solver);
  if (flags & ODF_TEST) odf_finalize(&odf);

  /* free parameters */
  if (NP1) free(lP);
  if (lr) free(r);
  if (lA) free(A);
  if (NP) free(lh);
  if (lgh) free(gh);
  free(zbfm.c_iter);
  free(zbfm.P);
  free(refl);
  free(refl_ext);

  /*free(zbfm.P_hat);*/

  nfsft_forget();

  return(0);
}
