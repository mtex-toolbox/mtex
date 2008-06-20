#include <wigner.h>
#include <api.h>
#include <math.h>





double SO3_gamma_al ( int m1,
		  int m2,
		  int j )
{
  double dj, dm1, dm2, M, mini;
  static int i;
  static double result;
  
  dj = (double) j ;
  dm1 = (double) m1 ;
  dm2 = (double) m2 ;
  M = (double)  (ABS(m1)>ABS(m2)?ABS(m1):ABS(m2));
  mini = (double)  (ABS(m1)<ABS(m2)?ABS(m1):ABS(m2));

  if (j == -1) 
  {
/* Constant is ((2n)!)^(1/2) / (2^n n!). */
    result = 1.0;
    for (i = 1; i <= M-mini; i++)
    {  

      result *= (M+mini+i)/(4.0*i);                                      
    }  
    return (1/pow(2,mini)*sqrt(result));

/*    result = 1/pow(2,M)  *  sqrt(fac(2*M)/(fac(M+mini)*fac(M-mini)));                       
     if ((m1+m2)%2==1)
     {
	 if (abs(m1)>abs(m2)) 
	{
	if(dm1>=0) result=(-1)*result;
	}
	else 
	{
	if (dm2<0) result=(-1)*result;
	}
    }
    return result;
*/
}
  else if (j <= M) 
  {
    return (0.0);
  }
  else 
  {
    return (
	    //sqrt( (2.*dj + 3.)/(2.*dj - 1.) ) *
	    -(dj + 1.)/sqrt(((dj+1.)*(dj+1.) - dm1*dm1)*
			   ((dj+1.)*(dj+1.) - dm2*dm2)) *
	    sqrt( (dj*dj - dm1*dm1)*(dj*dj - dm2*dm2) ) / dj
	    );
  }
}
/*
inline double gamma_al(int k, int n)
{ 
  static int i;
  static double result;
  
  if (k == -1) 
  {
    result = 1.0;
    for (i = 1; i <= n; i++)
    {  
      result *= (n+i)/(4.0*i);                                      
    }  
    return (sqrt(result));
  }
  else if (k <= n) 
  {
    return (0.0);
  }
  else 
  {
    return (-sqrt(((double)(k-n)*(k+n))/(((k-n+1.0)*(k+n+1.0))))); 
  }
}
*/





/*******eigentlich alpha********************/


inline double SO3_alpha_al ( int m1,
		  int m2,
		  int j )
{
  double dj, dm1, dm2, M,mini, neg;
  dj = (double) j ;
  dm1 = (double) m1 ;
  dm2 = (double) m2 ;
  M = (double)  (ABS(m1)>ABS(m2)?ABS(m1):ABS(m2));
  mini = (double)  (ABS(m1)<ABS(m2)?ABS(m1):ABS(m2));

/**(-1) - Faktor der für k xor m negativ gebraucht wird */

if ((dm1<0 && dm2>=0)||(dm2<0 && dm1>=0) )
   {neg=-1.0;}
else 
   {neg=1.0;}


if (j == -1)
  {
    return (0.0); 
  }
  else if (j == 0)
  {
    if (dm1 == dm2)
    {
      return 1.0;
    }
    else
    {
      return (int)(dm1+dm2)%2==0?-1.0:0.0;
    }
}
else if (j < M-mini) 
  {
    return j%2==0?-1.0:1.0;
  }  
  else if(j<M)
{
return 1.0*neg;
}
else
 {
  return (
	  
	//sqrt( (2.*dj + 3.)/(2.*dj + 1.) ) *
	  (dj + 1.)*(2.*dj + 1.)/sqrt(((dj+1.)*(dj+1.) - dm1*dm1)*
				      ((dj+1.)*(dj+1.) - dm2*dm2))
	  ) ;
 }
}

/*

inline double alpha_al(int k, int n)
{ 
  if (k == -1)
  {
    return (0.0); 
  }
  else if (k == 0)
  {
    if (n == 0)
    {
      return 1;
    }
    else
    {
      return n%2==0?-1.0:0.0;
    }
  }
  else if (k < n) 
  {
    return k%2==0?-1.0:1.0;
  }  
  else 
  {
    return (2.0*k+1.0) / sqrt ((k-n+1.0) * (k+n+1.0));	      
  }
}*/


/**************eigentlich beta************/

double SO3_beta_al ( int m1,
		  int m2,
		  int j )
{
  double dj, dm1, dm2,M,mini;

  dj = (double) j ;
  dm1 = (double) m1 ;
  dm2 = (double) m2 ;
  M = (double)  (ABS(m1)>ABS(m2)?ABS(m1):ABS(m2));
  mini = (double)  (ABS(m1)<ABS(m2)?ABS(m1):ABS(m2));
  

if (0 <= j && j < M)
  {
   return (1.0);

  }
  else
  {
  if (dm1==0.|| dm2==0.)  
  return (0.0);
  else
  return ((-dm1*dm2*(2.*dj+1.)/dj)/sqrt(((dj+1.)*(dj+1.) - dm1*dm1)*((dj+1.)*(dj+1.) - dm2*dm2)));
  }


/*if (j==0)
	return 1.0;
else if (j==-1) 
	return 0;
else if (j<M)
	return 1.0 ;
else  
	return (-SO3_alpha_al(m1, m2,j) * dm1 * dm2 / ( dj * ( dj + 1. ) ) ) ;*/

}      




/*
inline double beta_al(int k, int n)
{
  if (0 <= k && k < n)
  {
    return (1.0);
  }
  else
  {
    return (0.0);
  }
}*/


/*compute the coefficients for all degrees*/							

inline void SO3_alpha_al_row(double *alpha, int N, int k, int m)
{
  int j;
  double *alpha_act = alpha;
  for (j = -1; j <= N; j++)
  {
    *alpha_act = SO3_alpha_al(k,m,j); 
    alpha_act++;
  }  
}

inline void SO3_beta_al_row(double *beta, int N, int k, int m)
{
  int j;
  double *beta_act = beta;
  for (j = -1; j <= N; j++)
  {
    *beta_act = SO3_beta_al(k,m,j); 
    beta_act++;
  }  
}

inline void SO3_gamma_al_row(double *gamma, int N, int k, int m)
{
  int j;
  double *gamma_act = gamma;
  for (j = -1; j <= N; j++)
  {
    *gamma_act = SO3_gamma_al(k,m,j); 
    gamma_act++;
  }  
}

/*compute for all degrees l and orders k*/

inline void SO3_alpha_al_matrix(double *alpha, int N, int m)
{
  int i,j;
  double *alpha_act = alpha;
  for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_alpha_al(i,m,j); 
      alpha_act++;
    }  
  }  
}

inline void SO3_beta_al_matrix(double *alpha, int N,int m)
{
  int i,j;
  double *alpha_act = alpha;
  for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_beta_al(i,m,j); 
      alpha_act++;
    }  
  }  
}

inline void SO3_gamma_al_matrix(double *alpha, int N, int m)
{
  int i,j;
  double *alpha_act = alpha;
  for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_gamma_al(i,m,j); 
      alpha_act++;
    }  
  }  
}



/*compute all 3termrecurrence coeffs*/


inline void SO3_alpha_al_all(double *alpha, int N)
{
int q; 
  int i,j,m;
  double *alpha_act = alpha;
q=0;
for (m=-N;m<=N;m++)
{
  for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_alpha_al(i,m,j); 
      fprintf(stdout,"alpha_all_%d^[%d,%d]=%f\n",j,i,m,SO3_alpha_al(i,m,j));
      alpha_act++;
     q=q+1;

    }  
  }  
}
}

inline void SO3_beta_al_all(double *alpha, int N)
{
  int i,j,m;
  double *alpha_act = alpha;
for (m=-N;m<=N;m++)
{
  for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_beta_al(i,m,j); 
      alpha_act++;
    }  
  }  
}
}

inline void SO3_gamma_al_all(double *alpha, int N)
{
  int i,j,m;
  double *alpha_act = alpha;
  for (m=-N;m<=N;m++)
{
for (i = -N; i <= N; i++)
  {
    for (j = -1; j <= N; j++)
    {
      *alpha_act = SO3_gamma_al(i,m,j); 
      alpha_act++;
    }  
  }  
}
}

inline void eval_wigner(double *x, double *y, int size, int k, double *alpha, 
  double *beta, double *gamma)
{
  /* Evaluate the wigner function d_{k,nleg} (l,x) for the vector 
   * of knots  x[0], ..., x[size-1] by the Clenshaw algorithm
   */
  int i,j;
  double a,b,x_val_act,a_old;
  double *x_act, *y_act;  
  double *alpha_act, *beta_act, *gamma_act;
  
  /* Traverse all nodes. */
  x_act = x;
  y_act = y;
  for (i = 0; i < size; i++)
  {
    a = 1.0;
    b = 0.0;
    x_val_act = *x_act;
    
    if (k == 0)
    {  
      *y_act = 1.0;
    }
    else
    {
      alpha_act = &(alpha[k]);
      beta_act = &(beta[k]);
      gamma_act = &(gamma[k]);
      for (j = k; j > 1; j--)
      {
        a_old = a;
        a = b + a_old*((*alpha_act)*x_val_act+(*beta_act));		        
	       b = a_old*(*gamma_act);
        alpha_act--;
        beta_act--;
        gamma_act--;
      }
      *y_act = (a*((*alpha_act)*x_val_act+(*beta_act))+b);                  
    }
    x_act++;
    y_act++;
  }
}

inline int eval_wigner_thresh(double *x, double *y, int size, int k, double *alpha, 
  double *beta, double *gamma, double threshold)
{
  
  int i,j;
  double a,b,x_val_act,a_old;
  double *x_act, *y_act;
  double *alpha_act, *beta_act, *gamma_act;
  
  /* Traverse all nodes. */
  x_act = x;
  y_act = y;
  for (i = 0; i < size; i++)
  {
    a = 1.0;
    b = 0.0;
    x_val_act = *x_act;
    
    if (k == 0)
    {  
     *y_act = 1.0;
    }
    else
    {
      alpha_act = &(alpha[k]);
      beta_act = &(beta[k]);
      gamma_act = &(gamma[k]);
      for (j = k; j > 1; j--)
      {
        a_old = a;
        a = b + a_old*((*alpha_act)*x_val_act+(*beta_act));		        
	       b = a_old*(*gamma_act);
        alpha_act--;
        beta_act--;
        gamma_act--;
      }
      *y_act = (a*((*alpha_act)*x_val_act+(*beta_act))+b);                  
      if (fabs(*y_act) > threshold)
      {
        return 1;
      }
    }
    x_act++;
    y_act++;
  }
  return 0;
}

/************************************************************************/
/* L2 normed wigner little d, WHERE THE DEGREE OF THE FUNCTION IS EQUAL
   TO ONE OF ITS ORDERS. This is the function to use when starting the
   three-term recurrence at orders (m1,m2)

   Note that, by definition, since I am starting the recurrence with this
   function, that the degree j of the function is equal to max(abs(m1), abs(m2) ).
*/


double wigner_start( int m1,
		 int m2, double theta )
{

  int i, l, delta;
  int cosPower, sinPower;
  int absM1, absM2 ;
  double dl, dm1, dm2, normFactor, sinSign ;
  double dCP, dSP ;
  double max;
  double min;

  max = (double)  (ABS(m1)>ABS(m2)?ABS(m1):ABS(m2));
  min = (double)  (ABS(m1)<ABS(m2)?ABS(m1):ABS(m2));

  l = max ;
  delta = l - min ;

absM1=ABS(m1);
absM2=ABS(m2);
  dl = ( double ) l ;
  dm1 = ( double ) m1 ;
  dm2 = ( double ) m2 ;
  sinSign = 1. ;
  normFactor = 1. ;
  
  for ( i = 0 ; i < delta ; i ++ )
    normFactor *= sqrt( (2.*dl - ((double) i) )/( ((double) i) + 1.) );

  /* need to adjust to make the L2-norm equal to 1 */
 

normFactor *= sqrt((2.*dl+1.)/2.);

  if ( l == absM1 )
    if ( m1 >= 0 )
      {
	cosPower = l + m2 ;
	sinPower = l - m2 ;
	if ( (l - m2) % 2 )
	  sinSign = -1. ;
      }
    else
      {
	cosPower = l - m2 ;
	sinPower = l + m2 ;
      }
  else if ( m2 >= 0 )
    {
      cosPower = l + m1 ;
      sinPower = l - m1 ;
    }
  else
    {
      cosPower = l - m1 ;
      sinPower = l + m1 ;
      if ( (l + m1) % 2 )
	sinSign = -1. ;
    }

  dCP = ( double ) cosPower ;
  dSP = ( double ) sinPower ;

    return normFactor * sinSign *  pow( sin(theta/2), dSP ) * pow( cos(theta/2), dCP ) ;
}
