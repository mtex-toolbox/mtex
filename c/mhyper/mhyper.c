#include <mhyper.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>




/*
#ifdef _OPENMP
  #include <omp.h>
#endif
*/
//#include <mpfr.h>
//#include "gmp.h"

int digits;
long int prec; 
mpf_t delta, delta2;


void init_prec(int digit){ // precision issues
	/* set precision */
	digits = digit;
	prec = digits * sizeof(mp_limb_t);
	mpf_set_default_prec( prec );	
	//mpfr_set_default_prec ( digits*4 );
	
	/* set delta */
	mpf_init(delta);
	mpf_set_d(delta,10);
	mpf_pow_ui(delta,delta,digits/2+1); //- digits*1/4); 
	mpf_ui_div(delta,5,delta);
	
	mpf_init(delta2);
	mpf_mul_ui(delta2,delta,2);
	
	//gmp_printf("precision : %d digits\n", digits);
	//gmp_printf("delta     : %.*Fe \n",4,delta2);
}


void print_N(mpf_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		gmp_printf (" %.*Fe\t", 10, a[k]);
	printf("\n");
}


void print_Nf(mpf_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		gmp_printf (" %.*Ff\t", 14, a[k]);
	printf("\n");
}


void print_NN(mpf_t **A,const int n){
	int k,l;
	for(k=0;k<n;k++){
		for(l=0;l<n;l++){
			gmp_printf (" %.*Fe \t", 8, A[k][l]);
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
  	double c1 = 0; 
	
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
	
	mpfr_init2(o,prec);
	mpfr_set_f(o, in, prec);
	mpfr_log(o, o, prec); /* take the natural logarithm */
	mpfr_get_f(out, o, prec);
	
	mpfr_clear(o);
}

void eval_exp_Ah(mpf_t C, double *f, int n){

	int k;
	
	mpfr_t fz, Cz;
	mpfr_init2(Cz,prec); mpfr_set_f(Cz, C, prec);
	mpfr_init2(fz, prec);
		
	for(k=0;k<n;k++){
		mpfr_init_set_d(fz,f[k],prec);
		mpfr_exp(fz,fz,prec);
		mpfr_div(fz,fz,Cz,prec);
		f[k] = mpfr_get_d(fz,prec);
	}

}

void eval_exp_besseli(double *a, double *bc, mpf_t C, int n){

	int k;
	
	mpfr_t az, bz, Cz;
	 
	mpfr_init2(Cz,prec); mpfr_set_f(Cz, C, prec);
	mpfr_init2(az, prec);
	mpfr_init2(bz, prec);
	
	//exp(a) ./ C .* besseli(0,sqrt(b.^2 + c.^2))
	
	for(k=0;k<n;k++){
		mpfr_init_set_d(az,a[k],prec);
		mpfr_init_set_d(bz,bc[k],prec);
		mpfr_exp(az,az,prec);
		mpfr_div(az,az,Cz,prec);
		mpfr_i0(bz,bz,prec);
		mpfr_mul(az,az,bz,prec);
		a[k] = mpfr_get_d(az,prec);
	}
}


int mpfr_i0(mpfr_t res, mpfr_srcptr z, mp_rnd_t r){
	// see mpfr_j0 / mpfr_jn

	 int inex;
  unsigned long absn;
  mp_prec_t prec, err;
  mp_exp_t exps, expT;
  mpfr_t y, s, t;
  unsigned long k, zz;
  MPFR_ZIV_DECL (loop);
  long n = 0;

  absn = SAFE_ABS (unsigned long, n);
  
  mpfr_init2 (y, 32);  
  mpfr_init (s);
  mpfr_init (t);

  prec = MPFR_PREC (res) + MPFR_PREC (res);  
  MPFR_ZIV_INIT (loop, prec);
  for (;;)
    {
      mpfr_set_prec (y, prec);
      mpfr_set_prec (s, prec);
      mpfr_set_prec (t, prec);
      mpfr_pow_ui (t, z, absn, GMP_RNDN); /* z^|n| */
      mpfr_mul (y, z, z, GMP_RNDN);       /* z^2 */
      zz = mpfr_get_ui (y, GMP_RNDU);
      MPFR_ASSERTN (zz < ULONG_MAX);
      mpfr_div_2ui (y, y, 2, GMP_RNDN);   /* z^2/4 */
      mpfr_fac_ui (s, absn, GMP_RNDN);    /* |n|! */
      mpfr_div (t, t, s, GMP_RNDN);
   //   if (absn > 0)
   //     mpfr_div_2ui (t, t, absn, GMP_RNDN);
      mpfr_set (s, t, GMP_RNDN);
      exps = MPFR_EXP (s);
      expT = exps;
      for (k = 1; ; k++)
        {
          mpfr_mul (t, t, y, GMP_RNDN);
        //  mpfr_neg (t, t, GMP_RNDN);  // else its j0 !
		  mpfr_div_ui (t, t, k * k, GMP_RNDN);
		  
          exps = MPFR_EXP (t);
          if (exps > expT)
            expT = exps;
          mpfr_add (s, s, t, GMP_RNDN);
          exps = MPFR_EXP (s);
          if (exps > expT)
            expT = exps;
          if (MPFR_EXP (t) + (mp_exp_t) prec <= MPFR_EXP (s) &&
              zz / (2 * k) < k + n)
            break;
        }
      /* the error is bounded by (4k^2+21/2k+7) ulp(s)*2^(expT-exps)
         <= (k+2)^2 ulp(s)*2^(2+expT-exps) */
      err = 2 * MPFR_INT_CEIL_LOG2(k + 2) + 2 + expT - MPFR_EXP (s);
      if (MPFR_LIKELY (MPFR_CAN_ROUND (s, prec - err, MPFR_PREC(res), r)))
          break;
      MPFR_ZIV_NEXT (loop, prec);
    }
  MPFR_ZIV_FREE (loop);

  inex = ((n >= 0) || ((n & 1) == 0)) ? mpfr_set (res, s, r)
                                      : mpfr_neg (res, s, r);

  mpfr_clear (y);
  mpfr_clear (s);
  mpfr_clear (t);
  

  return inex;
}


void copy(mpf_t *out, mpf_t *in,int n){
	int k;
	for(k=0;k<n;k++){
		mpf_set(out[k],in[k]);
	}
}


void dmhyper(mpf_t *df, mpf_t *kappa,int n){
	int k;
	
	/*  df = (f(x+h) - f(x-h)) / (h*2)	*/
	//#pragma omp parallel for private(k) shared(df,kappa) num_threads(n)
	for(k=0;k<n;k++){	
		mpf_t *tmp1, *tmp2;
		mpf_t d1, d2;
		
		int l;
		
		mpf_init(d1);  mpf_init(d2);
		tmp1 = (mpf_t*) malloc (n*sizeof(mpf_t));
		tmp2 = (mpf_t*) malloc (n*sizeof(mpf_t));  	
		//#pragma omp parallel for	
		for(l=0;l<n;l++){
			mpf_init(tmp1[l]);
			mpf_init(tmp2[l]);
		}	
		
		/* d1: f(x-h) */			
		copy(tmp1, kappa, n);
		mpf_sub(tmp1[k], tmp1[k], delta);
		mhyper(d1,tmp1,n);
		
		/* d2: f(x+h) */
		copy(tmp2, kappa, n);
		mpf_add(tmp2[k], tmp2[k], delta);
		mhyper(d2, tmp2, n);
		
		mpf_div(df[k], d2, d1);
		mpf_log(df[k], df[k]); /* log(f(x+h))- log(f(x-h)) : log(f(x+h)/f(x-h)) */
		mpf_div(df[k], df[k], delta2);
		
		free_N(tmp1,n);
		free_N(tmp2,n);
		mpf_clear(d1);
		mpf_clear(d2);
	}
	
	
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
	//#pragma omp parallel for
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
			mpf_set(tmp,z[k]);
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
			mpf_set(tmp,z[k]);
		}
	}
	
	mpf_clear(tmp);
	
	return pos;
}


void check_diag(mpf_t **A,const int n){
	int k;
	mpf_t tmp,zero;
		
	mpf_init(zero);
	mpf_init_set_d(tmp,1);
	
	for(k=0;k<n;++k){
		mpf_mul(tmp,tmp,A[k][k]);
	}
	
	if ( mpf_eq(tmp,zero,digits/2) ){
		printf("warning: system singular to working precision\n");
		//gmp_printf("det: %.*Fe ", 10, tmp);
		exit(0);
	}
	
	mpf_clear(tmp);
	mpf_clear(zero);
	
}


void swap_row_NN(mpf_t **A, int from, int to ,const int n){
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


void swap_row_N(mpf_t *b, int from, int to ,const int n){
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
	
	/* is singular? */
	check_diag(A,n);
	
	for(k=0; k<n;k++)
		mpf_init(x[k]); // clear values of x
	
	
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
		for (l=k+1; l<n; ++l){ 
			mpf_mul(tmp2, x[l], A[k][l]);
			mpf_sub(tmp1, tmp1, tmp2);
		}
		mpf_div(x[k], tmp1, A[k][k]);
    }
	
	mpf_clear(tmp1);
	mpf_clear(tmp2);
}


void guessinitial(mpf_t *kappa, mpf_t *lambda,const int n){
	mpf_t mm;
	int k,mpos;	
	
	mpf_init(mm);	
	mpos = max_N(lambda,n);
	for(k=0;k<n;++k){
		if (k != mpos){  // 1/2*(l-1)*l
			mpf_sub_ui(kappa[k],lambda[k],1);
			mpf_mul_ui(kappa[k],kappa[k],2);
			mpf_mul(kappa[k],kappa[k],lambda[k]);
			
			if( !mpf_eq(kappa[k],mm,digits/2) ) //omit x/0
				mpf_ui_div(kappa[k],1,kappa[k]);
			else {
				printf("warning: system might go infty, since one entry is zero\n");
				mpf_set_d(kappa[k],-10000);
			}
		}
	}
	
	mpf_set(mm, kappa[min_N(kappa,n)]);
	for(k=0;k<n;++k){
		mpf_sub(kappa[k],kappa[k],mm);
	}
	mpf_clear(mm);
}


void newton(int iters, mpf_t *kappa, mpf_t *lambda, int n){
	mpf_t *df, **jf, **pf, *dl, kappaN;
  mpf_t  t1,t2;
  int kpos;
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
	
/*	printf("\nstarting at: \n kappa :");
	print_N(kappa,n);
	printf("\n");
	*/

	mpf_init(t1); mpf_init(t2);
	
	
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
		
		//gmp_printf("iteration: %d, defect: %.*Fe\n", iter+1, 5, t2);
		//printf(" kappa :");  print_N(kappa,n);
		//printf(" lambda:");	 print_N(dl,n);
		//printf("\n");
		
		/*	*/	
		for(k=0;k<n;k++){
			mpf_set_d(jf[kpos][k], (k == kpos)?1:0);
			mpf_set_d(jf[k][kpos], (k == kpos)?1:0);
			}
		
		
		for(k=0;k<n;++k)
			if(k != kpos)
				mpf_sub(dl[k], dl[k], lambda[k]);
			
		mpf_sub(dl[kpos], kappa[kpos], kappaN);
		
		
		/*  inv(A)*b */
		solveAxb(df, jf, dl,n);
		
		
		for(k=0;k<n;++k)
			mpf_sub(kappa[k], kappa[k], df[k]);
		
		
		mpf_set(kappaN,kappa[min_N(kappa,n)]);
		for(k=0;k<n;++k)
			mpf_sub(kappa[k], kappa[k], kappaN);
		
	}	
	
	dmhyper(dl, kappa, n);
	
	/*printf("\n kappa             :");  print_Nf(kappa,n);
	printf(" approximate lambda:");	 print_Nf(dl,n);
	printf(" prescribed  lambda:");	 print_Nf(lambda,n);
	printf("\n");
	*/
	
	for(k=0;k<n;++k){
		mpf_sub(dl[k],dl[k],lambda[k]);
	}
	/*
	printf(" ( al - pl. )      :");	 print_N(dl,n);
	printf("\n");		
	*/
	free_N(df,n);
	free_N(dl,n);
	free_NN(jf,n);
	free_NN(pf,n);
	mpf_clear(kappaN);
	mpf_clear(t1);
	mpf_clear(t2);

};
