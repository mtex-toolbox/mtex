#include <stdio.h>
#include <stdlib.h>
#include <mhyper.h>

#include <math.h>
#include <pio.h>

#define Nparam 8

int main (int argc, char *argv[]){

	mpf_t *lambda, *kappa;
	
	char f_out_name[BUFSIZ];
	int d,iters,n, k, nk,nf,na,nb;
	double *lambdas, *kappas, *f,*a,*b;
		
	param_file_type param[Nparam] = 
    {{"d:"     , "%d", &d,       NULL, sizeof(int)},
     {"iter:"  , "%d", &iters,   NULL, sizeof(int)},
	 {"lambda:", "DATA_FILE", &lambdas, &n , sizeof(double)},
	 {"kappa:", "DATA_FILE", &kappas, &nk , sizeof(double)},  //psi
	 {"h:", "DATA_FILE", &f, &nf , sizeof(double)},           //odf
	 {"a:", "DATA_FILE", &a, &na , sizeof(double)},          //pdf a
	 {"bc:", "DATA_FILE", &b, &nb , sizeof(double)},          //pdf sqrt(b^2 + c^2)
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
		//printf("Some parameters not found!");
		//abort();
	}
	fclose(f_param);
	
	/* precission & delta */
	init_prec(d);

	
	if (nk>0) {   // kappas given
		mpf_t C;
		
		kappa = (mpf_t*) malloc (nk*sizeof(mpf_t));
		
		for(k=0;k<nk;k++){ 
			mpf_init(kappa[k]);
			mpf_init_set_d(kappa[k], kappas[k]);
		}
		
		mhyper(C, kappa, nk);
		
		// gmp_printf("C: %.*Fe \n ", 20, C);	
		
		if (nf>0) // eval odf values
		{
			eval_exp_Ah(C,f,nf);
			
			f_out = check_fopen(f_out_name,"wb");
			fwrite(f,sizeof(double),nf,f_out);
			fclose(f_out);
		} 
		if ( na > 0) {// eval pdf values
		
		/*	// testing BesselI[0,a]
			mpfr_t in, out;					
						
			for(k=0;k<na;k++){
			
				mpfr_init2(in, d);
				mpfr_set_d(in,	a[k],d);
				mpfr_init2(out, d);
				
				mpfr_i0(out, in, d);
				
				
				mpfr_printf ("%.1028RNf\ndd", out);
				
				a[k] = mpfr_get_d(out,d);
				
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
		
		if (nf == 0 && na == 0) { // only return constant		
	
			double CC = mpf_get_d(C);
			
			f_out = check_fopen(f_out_name,"wb");
			fwrite(&CC,sizeof(double),1,f_out);
			fclose(f_out);
		
		}
	
	} else {	// solve kappas
		/* copy input variables */	
		lambda = (mpf_t*) malloc (n*sizeof(mpf_t));
		kappa = (mpf_t*) malloc (n*sizeof(mpf_t));	
		
		for(k=0;k<n;k++){ 
				mpf_init(kappa[k]);
				mpf_init_set_d(lambda[k], lambdas[k]);
			}
				
		if(iters>0){		
			/* check input */
			mpf_t tmp;
			mpf_init(tmp);
			for(k=0;k<n;k++){
				mpf_add(tmp,tmp,lambda[k]);
			}
			
			mpf_ui_sub(tmp,1,tmp);
			mpf_div_ui(tmp,tmp,n);
			
			for(k=0;k<n;k++){ 		
				mpf_add(lambda[k],lambda[k],tmp);
			}
			
			mpf_init(tmp);
			for(k=0;k<n;k++){
				mpf_add(tmp,tmp,lambda[k]);
			}
			
			mpf_init(tmp);
			if( mpf_cmp(lambda[min_N(lambda,n)],tmp) < 0 ){
				printf("not well formed! sum should be exactly 1 and no lambda negativ");
				exit(0);
			}
			/* solve the problem */	
			newton(iters,kappa, lambda, n);

		} else {		
			dmhyper(kappa,lambda,n);
		}
		
				
		for(k=0;k<n;k++){
			lambdas[k] = mpf_get_d(kappa[k]);	// something wents wront in matlab for 473.66316276431799;
								// % bug:   lambda= [0.97 0.01 0.001];
		}
			
		f_out = check_fopen(f_out_name,"wb");
		fwrite(lambdas,sizeof(double),n,f_out);
		fclose(f_out);
		
		free_N(lambda,n);
		free_N(kappa,n);
		
	}
	
	
	

	
  
	return EXIT_SUCCESS;
}
