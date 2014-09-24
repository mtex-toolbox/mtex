#include <zbfm_solver.h>
#include <helper.h>
#include <string.h>

void zbfm_solver_init(zbfm_solver_plan *ths,
		      zbfm_plan *zbfm,
		      unsigned int flags,
		      char *fn){

  ths->zbfm = zbfm;
  ths->flags = flags;
  ths->iter = 0;
  ths->error_iter = 0;

  ths->descent_iter = 0;
  ths->descent_max = 0;

  strcpy(ths->file_name,fn);

}

void zbfm_solver_finalize(zbfm_solver_plan *ths){
  
}

void zbfm_print_flags(FILE *f,zbfm_solver_plan *ths){

  fprintf(f,"flags: ");
  if (ths->flags & WEIGHTS) fprintf(f,"WEIGHTS ");
  if (ths->flags & REGULARISATION) fprintf(f,"REGULARISATION ");
  if (ths->flags & RP_VALUES) fprintf(f,"RP_VALUES ");
  if (ths->flags & FORCE_ITER_MAX) fprintf(f,"FORCE_ITER_MAX ");
  if (ths->flags & ODF_TEST) fprintf(f,"ODF_TEST ");
  fprintf(f,"\n");
  fprintf(f,"iter_max: %d descent_min: %.4E\n",ths->iter_max,ths->descent_min);
}

void zbfm_solver_iterate(zbfm_solver_plan *ths){

 /* time_t rawtime; /*
 /* struct tm * timeinfo; /*
  
  fprintf(stdout,"start iteration\n");fflush(stdout);

  /* time ( &rawtime ); */
/*   timeinfo = localtime ( &rawtime ); */
/*   fprintf(stderr,"date: %s", asctime (timeinfo) ); */
/*   zbfm_print_flags(stderr,ths); */

  zbfm_before_loop(ths->zbfm);
  
  /* residual error */
  ths->error_iter = (ths->zbfm)->error; 
  fprintf(stdout,"error: %.4E ",ths->zbfm->error);fflush(stdout);

  /* output */
  /* if (ths->flags & ODF_TEST) */
/*     fprintf(stderr,"%.4E ",odf_error(ths->odf,ths->zbfm->c_iter)); */
  
/*   if (ths->flags & RP_VALUES) */
/*     fprintf(stderr,"%.4E ",calculate_RP(ths->zbfm)); */
  
/*   fprintf(stderr,"%.4E\n",ths->error_iter); */
/*   fflush(stderr); */



  ths->iter = 0;  

  /* iteration loop */
  while (ths->iter < ths->iter_max && 
	 (ths->flags & FORCE_ITER_MAX || ths->iter < ths->iter_min ||
	  ths->descent_iter >= ths->descent_max * ths->descent_min)) {
    /*printf("<%.4e> %d;",ths->descent_min,ths->iter_min);
      printf("[%.4e] ",ths->descent_iter/ths->descent_max);*/
    zbfm_one_step(ths->zbfm);

    /* check PDF error */
    ths->descent_iter = ths->error_iter / ths->zbfm->error -1;
    ths->error_iter   = ths->zbfm->error;
    if (ths->descent_iter > ths->descent_max) 
      ths->descent_max  =  ths->descent_iter;

    /* check ODF error and output*/
    fprintf(stdout,"%.4E ",ths->error_iter);fflush(stdout);
 
    /*     if (ths->flags & ODF_TEST) */
/*       fprintf(stderr,"%.4E ",odf_error(ths->odf,ths->zbfm->c_iter)); */

/*     if (ths->flags & RP_VALUES) */
/*       fprintf(stderr,"%.4E ",calculate_RP(ths->zbfm)); */
	
/*     fprintf(stderr,"%.4E\n",ths->error_iter); */
/*     fflush(stderr); */

    /* save result to disc */
    if (ths->flags & ODF_SAVE)
      zbfm_solver_save(ths);
      
    ths->iter++;
  }

  /* finalize */
  printf("\nFinished PDF-ODF inversion.\n");
  printf("error: %.4E\n",ths->error_iter);
  printf("alpha: ");print_double(stdout,ths->zbfm->alpha_iter,ths->zbfm->NP);printf("\n");

  
  /* time ( &rawtime ); */
/*   timeinfo = localtime ( &rawtime ); */
/*   fprintf(stderr,"\nalpha: ");print_double(stderr,ths->zbfm->alpha_iter,ths->zbfm->NP); */
/*   fprintf(stderr,"\ndate: %s\n", asctime (timeinfo) ); */
/*   fflush(stderr); */

}

void zbfm_solver_save(zbfm_solver_plan *ths){

  FILE *f_out;
  char fname[BUFSIZ] = "";
  
  sprintf(fname,"%s_%d",ths->file_name,ths->iter);
  f_out = fopen(fname,"w");
  fwrite(ths->zbfm->c_iter,sizeof(double),ths->zbfm->lc,f_out);
  fclose(f_out);   
}


  /* vpr_double(zbfm->a,zbfm->lc*NP,"a:"); */
  /* vpr_double(zbfm->alpha_iter,NP,"alpha_iter"); */
  /* vpr_double(zbfm->r_iter,zbfm->lP,"r_iter"); */

  /* printf("P:\n"); */
  /* print_double(stdout,zbfm->P,zbfm->lP);printf("\n"); */
  
  /* printf("\n------------------------------------------------------------------------\n"); */
  
/* vpr_double(zbfm->r_iter,zbfm->lP,"r_iter"); */
/* zbfm_before_loop(&zbfm); */

/* printf("ERROR = %.4E ",zbfm->error);  */
/* printf("alpha: %.4E \n",zbfm->alpha_iter[0]);  */
/* vpr_double(zbfm->r_iter,zbfm->lP,"r_iter"); */
  
