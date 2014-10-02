#include <mhyper.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>




/*
#ifdef _OPENMP
  #include <omp.h>
#endif
*/
/*#include <mpfr.h>*/
/*#include "gmp.h"*/

mp_rnd_t prec; 
mpfr_t delta, delta2;


void init_prec(int digit){ /* precision issues*/
	/* set precision */
	prec = digit;
	mpfr_set_default_prec( prec );
		
	/* set delta */
	mpfr_init_set_d(delta,10,prec);
	mpfr_pow_ui(delta,delta,prec/16,GMP_RNDN); /*- digits*1/4); */
	mpfr_ui_div(delta,5,delta,GMP_RNDN);
	
	mpfr_init2(delta2,prec);
	mpfr_mul_ui(delta2,delta,2,GMP_RNDN);
	
/*	mpfr_printf("precision : %d digits\n", digit);
	mpfr_printf (" %.16RE\t", delta);
	mpfr_printf (" %.16RE\t", delta2);
	*/
}


void print_N(mpfr_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		mpfr_printf (" %.12RE\t", a[k]);
	printf("\n");
}


void print_Nf(mpfr_t *a, const int n){
	int k;
	for(k=0;k<n;k++)
		mpfr_printf (" %.12RE\t", a[k]);
	printf("\n");
}


void print_NN(mpfr_t **A,const int n){
	int k,l;
	for(k=0;k<n;k++){
		for(l=0;l<n;l++){
			mpfr_printf (" %.12RE \t", A[k][l]);
		}
		printf("\n");
	}
}


void free_N(mpfr_t *t, const int n){
	int k;
	for(k=0;k<n;k++)
		mpfr_clear (t[k]);
	free(t);
}


void free_NN(mpfr_t **t, const int n){
	int k,l;
	for(k=0;k<n;k++){
		for(l=0;l<n;l++)
			mpfr_clear (t[k][l]);
		free(t[k]);
	}
	free(t);
}


void mhyper(mpfr_t f, mpfr_t *kappa,const long n){

	mpfr_t *p,*cp,*d; 
	mpfr_t tmp1,tmp2;
	int k,l;
  	double c1 = 0; 
	
	/* allocate memory */
	d = (mpfr_t*) malloc (n*sizeof(mpfr_t));  
	p = (mpfr_t*) malloc (n*sizeof(mpfr_t));  
	cp = (mpfr_t*) malloc ((n+1)*sizeof(mpfr_t));
	
	/* init variables */
	for(k=0;k<n;k++){ 
		mpfr_init_set_d(d[k],0.5,prec);
		mpfr_init_set_ui(p[k],0,prec);
		mpfr_init_set_ui(cp[k+1],0,prec);
	}
	
			
	/* function value */
	mpfr_init_set_d(f,1.0,prec);
	
	/* init characteristic polynomial */
	mpfr_init_set_ui(cp[0],1,prec);
	/* characteristic polynomial */	
	
	mpfr_init2(tmp1,prec); mpfr_init2(tmp2,prec);
	
	for(k=0;k<n;k++) 
		for(l=k+1;l>0;l--){
			mpfr_mul(tmp1, kappa[k], cp[l-1],GMP_RNDN);
			mpfr_sub(cp[l], cp[l], tmp1,GMP_RNDN);
			}

			
		
	/* init p */	
	for(k=0;k<n;k++) mpfr_set(p[k],cp[n-k],prec);
	
	
	/*the first few steps are a little different*/
	for(k=1;k<n;k++){
		mpfr_set_ui(d[k],0,prec);
		for(l=0;l<k;l++){	
			mpfr_set_si(tmp2,-k-l,prec);
			
			mpfr_mul(tmp2, tmp2, cp[k-l],GMP_RNDN);
			mpfr_mul(tmp2, tmp2, d[l],GMP_RNDN);
			mpfr_add(d[k],d[k],tmp2,GMP_RNDN);
		}
		
		mpfr_set_ui(tmp2,2*k,prec);
		mpfr_div(d[k],d[k],tmp2,GMP_RNDN);
		
		mpfr_add(f,f,d[k],GMP_RNDN);
		
		for(l=0;l<n;l++){
			mpfr_set_ui(tmp2,2+k,GMP_RNDN);
			mpfr_div(d[l],d[l],tmp2,GMP_RNDN);
		}
	}
	
	
	/*k -=1; */
	mpfr_t old_f;
	mpfr_init2(old_f,prec);
	for (;;)
	{	
		mpfr_set(old_f,f,prec);
		mpfr_set_ui(tmp1,0,prec);	
		
		c1 = -(2*k-n);
		for(l=0;l<n;l++){
			mpfr_set_si(tmp2, c1-l,prec);
			mpfr_mul(tmp2,tmp2,p[l],GMP_RNDN);
			mpfr_mul(tmp2,tmp2,d[l],GMP_RNDN);
			mpfr_add(tmp1,tmp1,tmp2,GMP_RNDN);
		}
		mpfr_set_ui(tmp2,2*k,prec);
		mpfr_div(tmp1,tmp1,tmp2,GMP_RNDN);
	
		/* add to function */
		mpfr_add(f,f,tmp1,GMP_RNDN);		
		
		/* divide and cycle entries */
		mpfr_set_ui(tmp2,k+2,prec);
		for(l=0;l<n-1;l++){
			mpfr_div(d[l],d[l+1],tmp2,GMP_RNDN);
		}
		
		mpfr_div(d[l],tmp1,tmp2,GMP_RNDN);
		
		/* increase */
		k+=1;
	
		if ( mpfr_eq(old_f,f,prec-1) > 0)
		 break;
		
	}
		
	free_N(cp,n+1);
	free_N(d,n);
	free_N(p,n);
	mpfr_clear(tmp1);
	mpfr_clear(tmp2);
	
}


void eval_exp_Ah(mpfr_t C, double *f, int n){

	int k;
	
	mpfr_t fz;
	mpfr_init2(fz, prec);
		
	for(k=0;k<n;k++){
		mpfr_init_set_d(fz,f[k],prec);
		mpfr_exp(fz,fz,GMP_RNDN);
		mpfr_div(fz,fz,C,GMP_RNDN);
		f[k] = mpfr_get_d(fz,GMP_RNDN);
	}

}

void eval_exp_besseli(double *a, double *bc, mpfr_t C, int n){

	int k;
	
	mpfr_t az, bz;
	mpfr_init2(az, prec);
	mpfr_init2(bz, prec);
	
	/*exp(a) ./ C .* besseli(0,sqrt(b.^2 + c.^2))*/
	
	for(k=0;k<n;k++){
		mpfr_init_set_d(az,a[k],prec);
		mpfr_init_set_d(bz,bc[k],prec);
		mpfr_exp(az,az,GMP_RNDN);
		mpfr_div(az,az,C,GMP_RNDN);
		mpfr_i0(bz,bz,GMP_RNDN);
		mpfr_mul(az,az,bz,GMP_RNDN);
		a[k] = mpfr_get_d(az,GMP_RNDN);
	}
}


int mpfr_i0(mpfr_t res, mpfr_srcptr z, mp_rnd_t r){
	/* see mpfr_j0 / mpfr_jn */

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
   /*   if (absn > 0)*/
   /*     mpfr_div_2ui (t, t, absn, GMP_RNDN);*/
      mpfr_set (s, t, GMP_RNDN);
      exps = MPFR_EXP (s);
      expT = exps;
      for (k = 1; ; k++)
        {
          mpfr_mul (t, t, y, GMP_RNDN);
        /*  mpfr_neg (t, t, GMP_RNDN);   else its j0 !*/
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


void copy(mpfr_t *out, mpfr_t *in,int n){
	int k;
	
	for(k=0;k<n;k++){
		mpfr_init_set(out[k],in[k],prec);
	}
}


void dmhyper(mpfr_t *df, mpfr_t *kappa,int n){
	int k,l;
	mpfr_t *tmp1, *tmp2;
	tmp1 = (mpfr_t*) malloc (n*sizeof(mpfr_t));
	tmp2 = (mpfr_t*) malloc (n*sizeof(mpfr_t));
		
    mpfr_t d1, d2;
	mpfr_init2(d1,prec);
	mpfr_init2(d2,prec);

	/*  df = (f(x+h) - f(x-h)) / (h*2)	*/
	for(k=0;k<n;k++){	
		mpfr_init2(df[k], prec);
		/* d1: f(x-h) */			
		copy(tmp1, kappa, n);	
		mpfr_sub(tmp1[k], tmp1[k], delta, GMP_RNDD);
		mhyper(d1, tmp1,n);
		
		/* d2: f(x+h) */
		copy(tmp2, kappa, n);		
		mpfr_add(tmp2[k], tmp2[k], delta, GMP_RNDU);	
		mhyper(d2, tmp2, n);
		
		mpfr_sub(df[k],d1,d2,GMP_RNDN);
		mpfr_div(df[k],df[k],delta2,GMP_RNDN);
		
		mpfr_div(df[k], d2, d1, GMP_RNDN);	
		mpfr_log(df[k], df[k], GMP_RNDN); /* log(f(x+h))- log(f(x-h)) : log(f(x+h)/f(x-h)) */
		mpfr_div(df[k], df[k], delta2, GMP_RNDN);
	}
	
	free_N(tmp1,n);
	free_N(tmp2,n);
	mpfr_clear(d1);
	mpfr_clear(d2);		
	
	
}


void jmhyper(mpfr_t **jf, mpfr_t *kappa,int n){
	mpfr_t *tmp1, *tmp11, *tmp2, *tmp22;
	mpfr_t d1,d2;
	int k,l;	
	
	mpfr_init2(d1,prec);
	mpfr_init2(d2,prec);
	
	tmp1 = (mpfr_t*) malloc (n*sizeof(mpfr_t));
	tmp2 = (mpfr_t*) malloc (n*sizeof(mpfr_t)); 
	tmp11 = (mpfr_t*) malloc (n*sizeof(mpfr_t));
	tmp22 = (mpfr_t*) malloc (n*sizeof(mpfr_t));

	for(k=0;k<n;k++){
		copy(tmp1, kappa,n);
		mpfr_sub(tmp1[k], tmp1[k], delta,GMP_RNDD);
		dmhyper(tmp11,tmp1,n);
		
		copy(tmp2, kappa,n);
		mpfr_add(tmp2[k], tmp2[k], delta,GMP_RNDU);
		dmhyper(tmp22,tmp2,n);
		
		for(l=0;l<n;l++){
			mpfr_init2(jf[k][l],prec);
			mpfr_sub(jf[k][l],tmp22[l],tmp11[l],GMP_RNDN);
			mpfr_div(jf[k][l],jf[k][l],delta2,GMP_RNDN);
		}
	
	}
	
	free_N(tmp1,n);
	free_N(tmp11,n);
	free_N(tmp2,n);
	free_N(tmp22,n);
	mpfr_clear(d1);
	mpfr_clear(d2);
}


int max_N(mpfr_t *z,const int n){
	int k=0, pos=0;
	mpfr_t tmp;
	
	mpfr_init_set(tmp,z[k],prec);
	
	for(k=1;k<n;k++){
		if ( mpfr_less_p(tmp,z[k]) ) {
			pos = k;
			mpfr_set(tmp,z[k],prec);
		}
	}
	
	mpfr_clear(tmp);
	
	return pos;
}


int min_N(mpfr_t *z,const int n){
	int k=0, pos=0;
	mpfr_t tmp;
	
	mpfr_init_set(tmp,z[k],prec);
	for(k=1;k<n;k++){
		if ( mpfr_greater_p(tmp,z[k]) ) {
			pos = k;
			mpfr_set(tmp,z[k],prec);
		}
	}
	
	mpfr_clear(tmp);
	
	return pos;
}


void check_diag(mpfr_t **A,const int n){
	int k;
	mpfr_t tmp,zero;
		
	mpfr_init2(zero,prec);
	mpfr_init_set_d(tmp,1,prec);
	
	for(k=0;k<n;++k){
		mpfr_mul(tmp,tmp,A[k][k],GMP_RNDN);
	}
	
	if ( mpfr_zero_p(tmp) ){
		printf("warning: system singular to working precision\n");
		/*mpfr_printf("det: %.18RE ", tmp);*/
		exit(0);
	}
	
	mpfr_clear(tmp);
	mpfr_clear(zero);
	
}


void swap_row_NN(mpfr_t **A, int from, int to ,const int n){
	mpfr_t *tmps1;
	tmps1 = A[to];
	A[to] = A[from];
	A[from] = tmps1;	
}


void swap_row_N(mpfr_t *b, int from, int to ,const int n){
	mpfr_t tmp1[1];	
	tmp1[0][0] = b[to][0];
	b[to][0]= b[from][0];
	b[from][0] = tmp1[0][0];
}


void pivot(mpfr_t **A, mpfr_t *b,const int n){
	int k,l;
	mpfr_t tmp1,tmp2;
	
	/*partial pivoting*/	
	for (l = 0; l < n; ++l){		
		mpfr_init_set_ui(tmp1,0,prec); 
		mpfr_init_set_ui(tmp2,0,prec);
		for (k = l+1; k < n; ++k){
			mpfr_abs(tmp2, A[k][l],GMP_RNDN);
						
			if ( mpfr_less_p(tmp1,tmp2) ){
				mpfr_set(tmp1,tmp2,prec);
				swap_row_NN(A,k,l,n);
				swap_row_N(b,k,l,n);
			}
		}	
	}
}


void solveAxb(mpfr_t *x, mpfr_t **A, mpfr_t *b ,int n){
	int k,l,m;
	mpfr_t tmp1,tmp2;
	mpfr_init2(tmp1,prec);
	mpfr_init2(tmp2,prec);
		
	pivot(A,b,n);
		
	/* is singular? */
	check_diag(A,n);
	
	for(k=0; k<n;k++)
		mpfr_init2(x[k],prec); /* clear values of x	*/
	
	/* gaussian elemination */

	/* upper triangle */
	for (k = 0; k < n; ++k)
      for (l = k+1; l < n; ++l) {
        mpfr_div(tmp1, A[l][k], A[k][k],GMP_RNDN);
        for (m = k; m<n; ++m){
			mpfr_mul(tmp2,tmp1,A[k][m],GMP_RNDN);
			mpfr_sub(A[l][m],A[l][m],tmp2,GMP_RNDN);
		}
		mpfr_mul(tmp2,tmp1,b[k],GMP_RNDN);
		mpfr_sub(b[l],b[l], tmp2,GMP_RNDN);
	}	
	
	
	/* fill it */
	for (k = n-1; k>=0; --k) {
		mpfr_set(tmp1,b[k],GMP_RNDN);
		for (l=k+1; l<n; ++l){ 
			mpfr_mul(tmp2, x[l], A[k][l],GMP_RNDN);
			mpfr_sub(tmp1, tmp1, tmp2,GMP_RNDN);
		}
		mpfr_div(x[k], tmp1, A[k][k],GMP_RNDN);
    }
	
	mpfr_clear(tmp1);
	mpfr_clear(tmp2);
}


void guessinitial(mpfr_t *kappa, mpfr_t *lambda,const int n){
	mpfr_t mm;
	int k,mpos;	
	
	mpfr_init2(mm,prec);	
	mpos = max_N(lambda,n);
	for(k=0;k<n;++k){
		if (k != mpos){  /* 1/2*(l-1)*l*/
			mpfr_sub_ui(kappa[k],lambda[k],1,prec);
			mpfr_mul_ui(kappa[k],kappa[k],2,GMP_RNDN);
			mpfr_mul(kappa[k],kappa[k],lambda[k],GMP_RNDN);
			
			if( !mpfr_eq(kappa[k],mm,prec/2) ) /*omit x/0*/
				mpfr_ui_div(kappa[k],1,kappa[k],GMP_RNDN);
			else {
				printf("warning: system might go infty, since one entry is zero\n");
				mpfr_set_d(kappa[k],-10000,prec);
			}
		}
	}
	
	mpfr_set(mm, kappa[min_N(kappa,n)],prec);
	for(k=0;k<n;++k){
		mpfr_sub(kappa[k],kappa[k],mm,GMP_RNDN);
	}
	mpfr_clear(mm);
	
}


void newton(int iters, mpfr_t *kappa, mpfr_t *lambda, int n){
	mpfr_t *df, **jf, *dl, kappaN;
	mpfr_t  t1,t2;
	int kpos;
	int k,l,iter;
	
	/* allocate memory & init variables */
	mpfr_init2(kappaN,prec);
	df = (mpfr_t*) malloc (n*sizeof(mpfr_t));  
	dl = (mpfr_t *) malloc (n*sizeof(mpfr_t));	
	jf = (mpfr_t **) malloc (n*sizeof(mpfr_t *));		
	for(k=0;k<n;k++)
		jf[k] = (mpfr_t *) malloc (n*sizeof(mpfr_t));	
	
	guessinitial(kappa,lambda,n);  /* solvesym*/
	
	mpfr_init2(t1,prec); mpfr_init2(t2,prec);
	
	for(iter=0;iter<iters;iter++){
		kpos = max_N(kappa,n);
		mpfr_set(kappaN, kappa[kpos],prec);
		
		dmhyper(dl, kappa, n);
		jmhyper(jf, kappa, n);
		
		/* verbose defect */
		/*mpfr_init_set_ui(t2,0,prec);
		for(k=0;k<n;k++){
			mpfr_sub(t1, dl[k],lambda[k],GMP_RNDN);
			mpfr_abs(t1,t1,GMP_RNDN);
			mpfr_add(t2,t2,t1,GMP_RNDN);
		}
		
		mpfr_printf("iteration: %d, defect: %.16RE\n", iter+1,  t2);
		printf(" kappa :");  print_N(kappa,n);
		printf(" lambda:");	 print_N(dl,n);*/
		/*printf("\n");*/

		/*	*/	
		for(k=0;k<n;k++){
			mpfr_set_d(jf[kpos][k], (k == kpos)?1:0,prec);
			mpfr_set_d(jf[k][kpos], (k == kpos)?1:0,prec);
			}
		
		
		for(k=0;k<n;++k)
			if(k != kpos)
				mpfr_sub(dl[k], dl[k], lambda[k],GMP_RNDN);
			
		mpfr_sub(dl[kpos], kappa[kpos], kappaN,GMP_RNDN);
		
		
		/*  inv(A)*b */
		solveAxb(df, jf, dl,n);
		
				
		for(k=0;k<n;++k)
			mpfr_sub(kappa[k], kappa[k], df[k],GMP_RNDN);
		
		
		mpfr_set(kappaN,kappa[min_N(kappa,n)],prec);
		for(k=0;k<n;++k)
			mpfr_sub(kappa[k], kappa[k], kappaN,prec);
			
		/*	exit(0);*/
		
	}	
	
/*	dmhyper(dl, kappa, n);
	
	printf("\n kappa             :");  print_Nf(kappa,n);
	printf(" approximate lambda:");	 print_Nf(dl,n);
	printf(" prescribed  lambda:");	 print_Nf(lambda,n);
	printf("\n");
	
	
	for(k=0;k<n;++k){
		mpfr_sub(dl[k],dl[k],lambda[k],prec);
	}
	*/
	/*
	printf(" ( al - pl. )      :");	 print_N(dl,n);
	printf("\n");		
	*/
	free_N(df,n);
	free_N(dl,n);
	free_NN(jf,n);
	mpfr_clear(kappaN);
	mpfr_clear(t1);
	mpfr_clear(t2);

};
