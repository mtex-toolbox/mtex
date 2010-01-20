#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <mpfr.h>
//#include "gmp.h"

int digits;
long int prec; 
mpf_t delta, delta2;


void init_prec(){ // precision issues
	/* set precision */
	prec = digits * sizeof(mp_limb_t);	
	mpf_set_default_prec( prec );	
	
	/* set delta */
	mpf_init(delta); 		
	mpf_set_d(delta,10);
	mpf_pow_ui(delta,delta,digits/2+1); //- digits*1/4); 
	mpf_ui_div(delta,5,delta);
	
	mpf_init(delta2);
	mpf_mul_ui(delta2,delta,2);
	
	gmp_printf("precession : %d digits\n", digits);
	gmp_printf("delta      : %.*Fe \n",4,delta2);
}


void print_N(mpf_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		gmp_printf (" %.*Fe\t", 4, a[k]);
	printf("\n");
}


void print_Nf(mpf_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		gmp_printf (" %.*Ff\t", 12, a[k]);
	printf("\n");
}


void print_NN(mpf_t **A,const int n){
	int k,l;
	for(k=0;k<n;k++){
		for(l=0;l<n;l++){
			gmp_printf (" %.*Ff \t", 8, A[k][l]);
		}
		printf("\n");
	}
}


void free_N(mpf_t *t, const int n){
	int k;
	for(k=0;k<n;k++)
		mpf_clear (t[k]);
	free(t);
}


void free_NN(mpf_t **t, const int n){
	int k,l;
	for(k=0;k<n;k++){
		for(l=0;l<n;l++)
			mpf_clear (t[k][l]);
		free(t[k]);
	}
	free(t);
}


void mhyper(mpf_t f, mpf_t *kappa,long n){

	mpf_t *p,*cp,*d; 
	mpf_t tmp1,tmp2,tmp3;
	int k,l;
	
	/* allocate memory */
	d = (mpf_t*) malloc (n*sizeof(mpf_t));  
	p = (mpf_t*) malloc (n*sizeof(mpf_t));  
	cp = (mpf_t*) malloc ((n+1)*sizeof(mpf_t));
	
	/* init variables */
	for(k=0;k<n;k++){ 
		mpf_init(d[k]);
		mpf_init(p[k]);
		mpf_init(cp[k+1]);    
		mpf_set_d(d[k], 0.5);		
	}
	
			
	/* function value */
	mpf_init(f);
	mpf_set_d(f,1.0);
	
	/* init characteristic polynomial */
	mpf_init(cp[0]);
	mpf_set_d(cp[0],1.0);
	/* characteristic polynomial */
	
	mpf_init(tmp1); mpf_init(tmp2); mpf_init(tmp3);
	for(k=0;k<n;k++) 
		for(l=k+1;l>0;l--){
			mpf_mul(tmp1, kappa[k], cp[l-1]);
			mpf_sub(cp[l], cp[l], tmp1);
			}

	/* init p */	
	for(k=0;k<n;k++) mpf_set(p[k],cp[n-k]);
		
	/*the first few steps are a little different*/
	for(k=1;k<n;k++){
		mpf_set_d(d[k],0.0);
		for(l=0;l<k;l++){	
			mpf_set_d(tmp2,-k-l);
			
			mpf_mul(tmp2, tmp2, cp[k-l]);
			mpf_mul(tmp2, tmp2, d[l]);
			mpf_add(d[k],d[k],tmp2);
		}
		
		mpf_set_d(tmp2,2*k);
		mpf_div(d[k],d[k],tmp2);
		
		mpf_add(f,f,d[k]);
		
		for(l=0;l<n;l++){
			mpf_set_d(tmp2,2+k);
			mpf_div(d[l],d[l],tmp2);
		}
	}
	
	
	//k -=1; 
	double c1; 
	while (! mpf_eq(tmp3,f,digits) ) {	
		mpf_set_d(tmp1,0.0);
		mpf_add(tmp3,f,tmp1); /* abort? */
		
		c1 = -(2*k-n);
		for(l=0;l<n;l++){
			mpf_set_d(tmp2, c1-l);				
			mpf_mul(tmp2,tmp2,p[l]);
			mpf_mul(tmp2,tmp2,d[l]);
			mpf_add(tmp1,tmp1,tmp2);
		}
		mpf_set_d(tmp2,2.0*k);
		mpf_div(tmp1,tmp1,tmp2);
	
		/* add to function */
		mpf_add(f,f,tmp1);		
		
		/* divide and cycle entries */
		mpf_set_d(tmp2,k+2.0);		
		for(l=0;l<n-1;l++){			
			mpf_div(d[l],d[l+1],tmp2);
		}
		
		mpf_div(d[l],tmp1,tmp2);		
		
		/* increase */
		k+=1;
	}
	
	
	free_N(cp,n+1);
	free_N(d,n);
	free_N(p,n);
	mpf_clear(tmp1);
	mpf_clear(tmp2);
	mpf_clear(tmp3);
	
	// gmp_printf ("after %d iterations : %.*Ff \n", k,100, f);
	
}


void mpf_log(mpf_t out, mpf_t in){
	mpfr_t o;
	
	mpfr_init2(o, prec);
	mpfr_set_f(o,in, prec);
	mpfr_log(o,o, prec); /* take the natural logarithm */
	mpfr_get_f(out,o, prec);
	
	mpfr_clear(o);
}


void copy(mpf_t *out, mpf_t *in,int n){
	int k;
	for(k=0;k<n;k++){
		mpf_set(out[k],in[k]);
	}
}


void dmhyper(mpf_t *df, mpf_t *kappa,int n){
	mpf_t *tmp1, *tmp2;
	mpf_t d1, d2;
	int k;
	
	mpf_init(d1);  mpf_init(d2);
	tmp1 = (mpf_t*) malloc (n*sizeof(mpf_t));
	tmp2 = (mpf_t*) malloc (n*sizeof(mpf_t));  		
	for(k=0;k<n;k++){
		mpf_init(tmp1[k]);
		mpf_init(tmp2[k]);
		//mpf_init(df[k]);
	}
	
	/*  df = (f(x+h) - f(x-h)) / (h*2)	*/
	for(k=0;k<n;k++){
		/* d1: f(x-h) */
		copy(tmp1, kappa, n);		
		mpf_sub(tmp1[k], tmp1[k], delta);
		mhyper(d1,tmp1,n);
		
		mpf_log(d1,d1);
		
		/* d2: f(x+h) */
		copy(tmp2, kappa, n);
		mpf_add(tmp2[k], tmp2[k], delta);			
		mhyper(d2, tmp2, n);		
		mpf_log(d2, d2);
			
		mpf_sub(df[k], d2, d1);
		mpf_div(df[k], df[k], delta2);		
	}
	
	free_N(tmp1,n);
	free_N(tmp2,n);
	mpf_clear(d1);
	mpf_clear(d2);
}


void jmhyper(mpf_t **jf, mpf_t *kappa,int n){
	mpf_t *tmp1, *tmp11, *tmp2, *tmp22;
	mpf_t d1,d2;
	int k,l;
	
	
	mpf_init(d1);
	mpf_init(d2);
	tmp1 = (mpf_t*) malloc (n*sizeof(mpf_t));
	tmp2 = (mpf_t*) malloc (n*sizeof(mpf_t)); 
	tmp11 = (mpf_t*) malloc (n*sizeof(mpf_t));
	tmp22 = (mpf_t*) malloc (n*sizeof(mpf_t)); 	
	for(k=0;k<n;k++){
		mpf_init(tmp1[k]);
		mpf_init(tmp2[k]);
		mpf_init(tmp11[k]);
		mpf_init(tmp22[k]);
	}		
	
	
	for(k=0;k<n;k++){
		copy(tmp1, kappa,n);		
		mpf_sub(tmp1[k], tmp1[k], delta);
		dmhyper(tmp11,tmp1,n);
		
		copy(tmp2, kappa,n);
		mpf_add(tmp2[k], tmp2[k], delta);		
		dmhyper(tmp22,tmp2,n);
		
		for(l=0;l<n;l++){
			mpf_sub(jf[k][l],tmp22[l],tmp11[l]);
			mpf_div(jf[k][l],jf[k][l],delta2);
		}
				
	}
	
	free_N(tmp1,n);
	free_N(tmp11,n);
	free_N(tmp2,n);
	free_N(tmp22,n);
	mpf_clear(d1);
	mpf_clear(d2);
}


int max_N(mpf_t *z,const int n){
	int k=0, pos=0;
	mpf_t tmp;
	
	mpf_init_set(tmp,z[k]);
	
	for(k=1;k<n;k++){
		if ( mpf_cmp(tmp,z[k]) < 0) {
			pos = k;
		}
	}
	
	mpf_clear(tmp);
	
	return pos;
}


int min_N(mpf_t *z,const int n){
	int k=0, pos=0;
	mpf_t tmp;
	
	mpf_init_set(tmp,z[k]);
	
	for(k=1;k<n;k++){
		if ( mpf_cmp(tmp,z[k]) > 0) {
			pos = k;
		}
	}
	
	mpf_clear(tmp);
	
	return pos;
}


void check_diag(mpf_t **A,const int n){
	int k, w=0;
	mpf_t tmp;
	for(k=0;k<n;k++){
		mpf_abs(tmp,A[k][k]);
		if (mpf_cmp(tmp,delta) < 0) {
			w = 1;
		}
	}

	if (w) printf("warning: instable, increasing of precession might help\n");
	
	
	print_NN(A,n);
	
}


static inline void swap_row_NN(mpf_t **A, int from, int to ,const int n){
	int l;
	mpf_t tmp;
	
	mpf_init(tmp);	
	for(l=0;l<n;++l){
		mpf_set(tmp,A[to][l]);
		mpf_set(A[to][l],A[from][l]);
		mpf_set(A[from][l],tmp);	
	}
	
	mpf_clear(tmp);
}


static inline void swap_row_N(mpf_t *b, int from, int to ,const int n){
	mpf_t tmp;	
	mpf_init(tmp);	
	
	mpf_set(tmp,b[to]);
	mpf_set(b[to],b[from]);
	mpf_set(b[from],tmp);	
	
	mpf_clear(tmp);
}


void pivot(mpf_t **A, mpf_t *b,const int n){
	int k,l;
	mpf_t tmp1,tmp2;
	
	/*partial pivoting*/	
	for (l = 0; l < n; ++l){		
		mpf_init(tmp1); mpf_init(tmp2);
		for (k = l+1; k < n; ++k){
			mpf_abs(tmp2, A[k][l]);
			if (mpf_cmp(tmp1,tmp2) < 0){
				mpf_set(tmp1,tmp2);
				swap_row_NN(A,k,l,n);
				swap_row_N(b,k,l,n);
			}
		}	
	}
}


void solveAxb(mpf_t *x, mpf_t **A, mpf_t *b ,int n){
	int k,l,m;
	mpf_t tmp1,tmp2;
	mpf_init(tmp1);
	mpf_init(tmp2);
	
	pivot(A,b,n);	
	
	for(k=0; k<n;k++)
		mpf_init(x[k]); // clear values of x
	
	//check_diag(A,n);
	
	/* gaussian elemination */
	
	/* upper triangle */
	for (k = 0; k < n; ++k)
      for (l = k+1; l < n; ++l) {	
        mpf_div(tmp1, A[l][k], A[k][k]); 	
        for (m = k; m<n; ++m){
			mpf_mul(tmp2,tmp1,A[k][m]);
			mpf_sub(A[l][m],A[l][m],tmp2);
		}
		mpf_mul(tmp2,tmp1,b[k]);
		mpf_sub(b[l],b[l], tmp2);
	}
	
	/* fill it */
	for (k = n-1; k>=0; --k) {
		mpf_set(tmp1,b[k]);
		for (int l=k+1; l<n; ++l){ 
			mpf_mul(tmp2, x[l], A[k][l]);
			mpf_sub(tmp1, tmp1, tmp2);
		}
		mpf_div(x[k], tmp1, A[k][k]);
    }
	
	mpf_clear(tmp1);
	mpf_clear(tmp2);
}


void guessinitial(mpf_t *kappa, mpf_t *lambda,const int n){
	mpf_t *df, lower, upper, mm, half;
	int k;
	
	mpf_init_set_d(lower,0);
	mpf_init_set_d(upper,2500);
	mpf_init_set_d(half,0.5);
	mpf_init(mm);
	df = (mpf_t*) malloc (n*sizeof(mpf_t));  
	for(k=0;k<n;++k){
		mpf_init(df[k]);	
	}
	
	int kpos = max_N(lambda,n);
	
	for(k=0;k<25;++k){	
		mpf_add(mm,upper,lower);
		mpf_div_ui(mm,mm,2);
		
		mpf_set(kappa[kpos],mm);	
		dmhyper(df,kappa,n);

		if( mpf_cmp(lambda[kpos],df[kpos]) >= 0){
			mpf_set(lower,mm);
		} else {
			mpf_set(upper,mm);
		}
	}
	
	free_N(df,n);
	mpf_clear(lower);
	mpf_clear(upper);
	mpf_clear(mm);
	mpf_clear(half);
}


void newton(int iters, mpf_t *kappa, mpf_t *lambda, int n){
	mpf_t *df, **jf, **pf, *dl, kappaN;
	int k,l,iter;
	
	/* allocate memory & init variables */
	mpf_init(kappaN);
	df = (mpf_t*) malloc (n*sizeof(mpf_t));  
	dl = (mpf_t *) malloc (n*sizeof(mpf_t));
	
	jf = (mpf_t **) malloc (n*sizeof(mpf_t *)); 
	pf = (mpf_t **) malloc (n*sizeof(mpf_t *));
		
	for(k=0;k<n;k++){
		mpf_init(df[k]);
		mpf_init(dl[k]);
	
		jf[k] = (mpf_t *) malloc (n*sizeof(mpf_t));
		pf[k] = (mpf_t *) malloc (n*sizeof(mpf_t));
		for(l=0;l<n;l++){ 
			mpf_init(jf[k][l]);
			mpf_init(pf[k][l]);
		}
		
	}	
	
	guessinitial(kappa,lambda,n);  // solvesym
	
	printf("\nstarting at: \nkappa :");
	print_N(kappa,n);
	printf("\n");
	
	mpf_t  t1,t2;
	mpf_init(t1); mpf_init(t2);
	int kpos;
	
	for(iter=0;iter<iters;iter++){		
		kpos = max_N(kappa,n);		
		mpf_set(kappaN, kappa[kpos]);
		
		dmhyper(dl, kappa, n);
		jmhyper(jf, kappa, n);
	
	
		/* verbose defect */
		mpf_init(t2);
		for(k=0;k<n;k++){
			mpf_sub(t1, dl[k],lambda[k]);
			mpf_abs(t1,t1);
			mpf_add(t2,t2,t1);		
		}		
		
		gmp_printf("k = %d, defect = %.*Fe :\n", iter+1, 5, t2);
		
		/*	*/	
		for(k=0;k<n;k++)
			mpf_set_d(jf[kpos][k], (k == kpos)?1:0);
	
		printf(" kappa :");  print_N(kappa,n);
		printf(" lambda:");	 print_N(dl,n);
		printf("\n");		
			
		for(k=0;k<n;++k)
			if(k != kpos)
			mpf_sub(dl[k], dl[k], lambda[k]);
			
		mpf_sub(dl[kpos], kappa[kpos], kappaN);
			
			
		solveAxb(df, jf, dl,n);
		
		for(k=0;k<n;++k)
			mpf_sub(kappa[k], kappa[k], df[k]);
		
		
		kpos = min_N(kappa,n);			
		for(k=0;k<n;++k)
			mpf_sub(kappa[k], kappa[k], kappa[kpos]);	
		
	}	
	
	dmhyper(dl, kappa, n);
	printf(" kappa             :");  print_Nf(kappa,n);
	printf(" approximate lambda:");	 print_Nf(dl,n);
	printf(" prescribed  lambda:");	 print_Nf(lambda,n);
	printf("\n");		
	
	free_N(df,n);
	free_N(dl,n);
	free_NN(jf,n);
	free_NN(pf,n);
	mpf_clear(kappaN);
	mpf_clear(t1);
	mpf_clear(t2);

};


int main (int argc, char *argv[]){

	mpf_t *lambda, *kappa;
	int n = argc-3,k,iters=10;
	
	if (n < 1){
		printf(" Solves by newtons method:       \n\n");
		printf("  d(1F1(1/2,2, K ))             \n");
		printf(" ------------------- = lambda_i \n");
		printf("        d(k_i)                  \n\n ");
		printf("Usage:  mhyper  d n  lamba_1 ... lambda_4 \n\n");
		printf(" where 'd' is a number of precession, 'n' the \n");
		printf(" number of iterations.\n");
		
		return EXIT_SUCCESS;
	}
	/* precission & delta */
	digits = atoi(argv[1]);	
	init_prec();	
	
	iters = atoi(argv[2]);	
	/* copy input variables */
	lambda = (mpf_t*) malloc (n*sizeof(mpf_t));
	kappa = (mpf_t*) malloc (n*sizeof(mpf_t));	
	for(k=0;k<n;k++){ 
		mpf_init(kappa[k]);
		mpf_init_set_str (lambda[k], argv[k+3], 0);
	}
	
	
	/* check input */
	/*for(k=0;k<n;k++){ 
		gmp_printf (" %.*Ff \n", digits, kappa[k]);
	}*/
		
	newton(iters,kappa, lambda, n);

	free_N(lambda,n);
	free_N(kappa,n);		
  
	return EXIT_SUCCESS;
}
