#include <stdio.h>
#include <stdlib.h>
#include <mhyper.h>

#include <math.h>
#include <pio.h>

#define Nparam 8

int main (int argc, char *argv[]){

	mpfr_t *lambda, *kappa;
	
	char f_out_name[BUFSIZ];
	int d,iters,n, k, nk,nf,na,nb;
	double *lambdas, *kappas, *f,*a,*b;
		
	param_file_type param[Nparam] = 
    {{"d:"     , "%d", &d,       NULL, sizeof(int)},
     {"iter:"  , "%d", &iters,   NULL, sizeof(int)},
	 {"lambda:", "DATA_FILE", &lambdas, &n , sizeof(double)},
	 {"kappa:", "DATA_FILE", &kappas, &nk , sizeof(double)},  /*psi*/
	 {"h:", "DATA_FILE", &f, &nf , sizeof(double)},           /*odf*/
	 {"a:", "DATA_FILE", &a, &na , sizeof(double)},          /*pdf a*/
	 {"bc:", "DATA_FILE", &b, &nb , sizeof(double)},          /*pdf sqrt(b^2 + c^2)*/
	 {"res1:","%s ", &f_out_name,NULL, 0}};
    
	FILE *f_param;
	FILE *f_out;

	if (argc<2) {
		printf("Error! Missing parameter - parameter_file.\n");
		printf("%s\n",argv[0]);
		abort();
	}
	  
	/* read parameter file */
	f_param = check_fopen(argv[1],"r");
	if (read_param_file(f_param,param,Nparam,argc==2)<Nparam){	
		/*printf("Some parameters not found!");*/
		/*abort();*/
	}
	fclose(f_param);
	
	/* precission & delta */
	init_prec(d);
	
	long int prec = d;
	
	
	if (nk>0) {   /* kappas given*/
		mpfr_t C;
		
		kappa = (mpfr_t*) malloc (nk*sizeof(mpfr_t));
		
		for(k=0;k<nk;k++){ 
			mpfr_init2(kappa[k],prec);
			mpfr_init_set_d(kappa[k], kappas[k],prec);
		}
		
		mhyper(C, kappa, nk);
		
		/* gmp_printf("C: %.*Fe \n ", 20, C);	*/
		
		if (nf>0) /* eval odf values*/
		{
			eval_exp_Ah(C,f,nf);
			
			f_out = check_fopen(f_out_name,"wb");
			fwrite(f,sizeof(double),nf,f_out);
			fclose(f_out);
		} 
		if ( na > 0) {/* eval pdf values*/
		
		/* testing BesselI[0,a]
			mpfr_t in, out;					
						
			for(k=0;k<na;k++){
			
				mpfr_init2(in, prec);
				mpfr_set_d(in,	a[k],prec);
				mpfr_init2(out, prec);
				
				mpfr_i0(out, in, prec);
				
				
				mpfr_printf ("%.1028RNf\ndd", out);
				
				a[k] = mpfr_get_d(out,prec);
				
			}
				
			f_out = check_fopen(f_out_name,"wb");
			fwrite(a,sizeof(double),na,f_out);
			fclose(f_out);
		*/
		
			
			eval_exp_besseli(a,b,C,na);
				
			f_out = check_fopen(f_out_name,"wb");
			fwrite(a,sizeof(double),na,f_out);
			fclose(f_out);
		}
		
		if (nf == 0 && na == 0) { /* only return constant */
	
			double CC = mpfr_get_d(C,prec);
			
			f_out = check_fopen(f_out_name,"wb");
			fwrite(&CC,sizeof(double),1,f_out);
			fclose(f_out);
		
		}
	
	} else {	/* solve kappas */
		/* copy input variables */	
		lambda = (mpfr_t*) malloc (n*sizeof(mpfr_t));
		kappa = (mpfr_t*) malloc (n*sizeof(mpfr_t));	
		
		for(k=0;k<n;k++){ 
				mpfr_init_set_ui(kappa[k],0,prec);
				mpfr_init_set_d(lambda[k],lambdas[k],prec);
			}
			
				
		if(iters>0){		
			/* check input */
			mpfr_t tmp;
			mpfr_init(tmp);
			mpfr_set_d(tmp,0,prec);
			
			for(k=0;k<n;k++){
				mpfr_add(tmp,tmp,lambda[k],prec);
			}
			
			mpfr_ui_sub(tmp,1,tmp,prec);
			mpfr_div_ui(tmp,tmp,n,prec);
			
			for(k=0;k<n;k++){ 		
				mpfr_add(lambda[k],lambda[k],tmp,prec);
			}
			
			mpfr_init2(tmp,prec);
			for(k=0;k<n;k++){
				mpfr_add(tmp,tmp,lambda[k],prec);
			}
			
			mpfr_init2(tmp,prec);
			if( mpfr_cmp(lambda[min_N(lambda,n)],tmp) < 0 ){
				printf("not well formed! sum should be exactly 1 and no lambda negativ");
				exit(0);
			}
			
			
			/* solve the problem */	
			newton(iters,kappa, lambda, n);

		} else {
			guessinitial(kappa, lambda, n);
		}
		
				
		for(k=0;k<n;k++){
			lambdas[k] = mpfr_get_d(kappa[k],GMP_RNDN);	/* something wents wront in matlab for 473.66316276431799;*/
								/* % bug:   lambda= [0.97 0.01 0.001];*/
		}
			
		f_out = check_fopen(f_out_name,"wb");
		fwrite(lambdas,sizeof(double),n,f_out);
		fclose(f_out);
		
		free_N(lambda,n);
		free_N(kappa,n);
		
	}
	
	
	

	
  
	return EXIT_SUCCESS;
}
