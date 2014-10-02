#include "S2Grid.c"



typedef struct SO3Grid_ {
  
  S2Grid alphabeta;
  S1Grid *gamma;
  double *gamma_large;
  int *igamma;
  int n, nalphabeta, ngamma;

  buffer alphabeta_buffer;

} SO3Grid; 

typedef struct inddist_ {

  int ind;
  double dist;

} inddist;


void SO3Grid_init(SO3Grid ths[],
		  double alpha[],
		  double beta[],
		  double gamma[],
		  double sgamma[], /* gamma shift */
		  int igamma[],    /* segmentation og gamma*/
		  int ialphabeta[],/* segmentation of alphabeta*/
		  int nbeta,       /* number of beta lists */
		  double palpha,   /* period of alpha */
		  double pgamma)
{
  int i;
  /*printf("[%d,%d]",nalphabeta,ngamma);*/

  ths->nalphabeta = ialphabeta[nbeta];
  ths->n = igamma[ths->nalphabeta];
  ths->igamma = igamma;

  S2Grid_init(&ths->alphabeta, alpha, beta, nbeta, ialphabeta, palpha);

  ths->gamma = (S1Grid*) mxCalloc(ths->nalphabeta,sizeof(S1Grid));
  for (i=0;i<ths->nalphabeta;i++)
    S1Grid_init(&ths->gamma[i],&gamma[igamma[i]],
		ths->igamma[i+1]-ths->igamma[i],sgamma[i],pgamma);
  ths->gamma_large = gamma;

  buffer_init(&ths->alphabeta_buffer,ths->nalphabeta);

}

void SO3Grid_print(SO3Grid ths[])
{
  printf("alphabeta: \n");
  S2Grid_print(&ths->alphabeta);
  printf("gamma: \n");
  S1Grid_print(&ths->gamma[1]);
		       
}

void SO3Grid_finalize(SO3Grid *ths)
{
  int i;
  for (i=0;i < ths->nalphabeta;i++)
    S1Grid_finalize(&ths->gamma[i]);
  mxFree(ths->gamma);
  S2Grid_finalize(&ths->alphabeta);
  buffer_finalize(&ths->alphabeta_buffer);
}

inddist SO3Grid_find(SO3Grid ths[],
		 double alpha,
		 double beta,
		 double gamma)
{

  int iab;
  double cxb,cxg,sxb,sxg;
  double yalpha,ybeta,dalpha;
  double cyb,syb;
  double cc,ss,cda,sda;
  double re,im,dg;
  double a,b,d,e;
  inddist id;

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxb = cos(beta); 
  sxb = sin(beta); 

  /* search alphabeta */
  buffer_reset(&ths->alphabeta_buffer);
  iab = S2Grid_find(&ths->alphabeta,beta,alpha);

  /* search gamma */

  /* extract found alpha and beta*/
  yalpha = ths->alphabeta.rho_large[iab];
  ybeta = ths->alphabeta.theta_large[iab];
  dalpha = MOD0(alpha-yalpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  gamma = MOD3(gamma,ths->gamma[iab].p,ths->gamma[iab].min);
  cxg = cos(gamma); sxg = sin(gamma);
  cyb = cos(ybeta); syb = sin(ybeta);
  cda = cos(dalpha); sda = sin(dalpha);    
    
    /* calculate delta gamma */ 
	cc = cxb*cyb;
	ss = sxb*syb;
	a = cc + ss*cda;	 
	d = (cc+1)*cda + ss;
	e = (cxb+cyb)*sda;	

	b = sqrt(d*d+e*e);		
	re = d*cxg-e*sxg;
	im = -d*sxg-e*cxg;
    dg = -atan2(im,re);
	

  id.ind =  ths->igamma[iab] + S1Grid_find(&ths->gamma[iab],dg);

  dg = MOD0(ths->gamma_large[id.ind]-dg, ths->gamma[iab].p);

  id.dist = cos(0.5*acos(MIN(1,MAX(-1, (-1.0 + a + b *  cos(dg))/2 ))));

  /*printf("%.4e %.4e %.4e \n",a,b,dg);*/

  return id;

}

void SO3Grid_find_region(SO3Grid ths[],
			 double alpha,
			 double beta,
			 double gamma,
			 double epsilon,
			 buffer ind_buffer[])
{

  int i, iab, ind_old;
  double cxb,cxg,sxb,sxg;
  double yalpha,ybeta,dalpha;
    double cyb,syb;
	double cda,sda;
  double a,b,c,d,e,cc,ss,re,im,dg;

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxb = cos(beta); sxb = sin(beta); 

  /* search alphabeta */
  buffer_reset(&ths->alphabeta_buffer);
  S2Grid_find_region(&ths->alphabeta,beta,alpha,
		     epsilon,&ths->alphabeta_buffer);
  /*buffer_print(&ths->alphabeta_buffer);*/
  /*print_double(ths->alphabeta.theta_large,10);*/
  

  /* search gamma */
  for (i=0;i<ths->alphabeta_buffer.used;i++) {

    /* extract found alpha and beta*/
    iab = ths->alphabeta_buffer.data[i];
    yalpha = ths->alphabeta.rho_large[iab];
    ybeta = ths->alphabeta.theta_large[iab];
    dalpha = MOD0(alpha-yalpha,ths->alphabeta.rho[0].p);
    /*printf("(%d, %.4e, %.4e)\n",iab,yalpha,ybeta);*/

    /* calculate sin and cos */
    gamma = MOD3(gamma,ths->gamma[iab].p,ths->gamma[iab].min);
    cxg = cos(gamma); sxg = sin(gamma);
    cyb = cos(ybeta); syb = sin(ybeta);
    cda = cos(dalpha); sda = sin(dalpha);    
    
    /* calculate delta gamma */ 
	cc = cxb*cyb;
	ss = sxb*syb;
	a = cc + ss*cda;	 
	d = (cc+1)*cda + ss;
	e = (cxb+cyb)*sda;	
	
  b = sqrt(d*d+e*e);
	c = (1 + 2*cos(epsilon) - a) / b; 
	    /*printf("(%d, %.4e, %.4e, %.4e)\n",iab,gamma,dg,c);*/
	     
    if (c > 1.0) continue;
    else if (c < -1.0 + 1e-10) c = 3.1416;
    else c = acos(c);	
		
	re = d*cxg-e*sxg;
	im = -d*sxg-e*cxg;
    dg = -atan2(im,re);
    /*printf("(%d, %.4e, %.4e)\n",iab,dg,acos(c));*/

    ind_old = ind_buffer->used;
    buffer_set_offset(ind_buffer,ths->igamma[iab]);
    S1Grid_find_region(&ths->gamma[iab],dg,c,
		       ind_buffer);    

  }
}


void SO3Grid_dist_region(SO3Grid ths[],
			 double alpha,
			 double beta,
			 double gamma,
			 double epsilon,
			 buffer ind_buffer[],
			 double_buffer dist_buffer[])
{

  int i, iab, j, ind_old;
  double cxb,cxg,cyb,syb,sxb,sxg,cda,sda;
  double yalpha,ybeta,dalpha; 
  double a,b,c,d,e,cc,ss,tmp1,re,im,dg,dg2;
   

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxb = cos(beta); sxb = sin(beta);

  /* search alphabeta */
  buffer_reset(&ths->alphabeta_buffer);
  S2Grid_find_region(&ths->alphabeta,beta,alpha,
		     epsilon,&ths->alphabeta_buffer);
			 
  /*print_double(ths->alphabeta.theta_large,10);*/
  /*buffer_print(&ths->alphabeta_buffer);*/
  /* search gamma */
  for (i=0;i<ths->alphabeta_buffer.used;i++) {

    /* extract found alpha and beta*/
    iab = ths->alphabeta_buffer.data[i];
    yalpha = ths->alphabeta.rho_large[iab];
    ybeta = ths->alphabeta.theta_large[iab];
    dalpha = MOD0(alpha-yalpha,ths->alphabeta.rho[0].p);
	/*printf("(%d, %.4e, %.4e)\n",iab,yalpha,ybeta);*/
	
	 /* calculate sin and cos */
    gamma = MOD3(gamma,ths->gamma[iab].p,ths->gamma[iab].min);
    cxg = cos(gamma); sxg = sin(gamma);
    cyb = cos(ybeta); syb = sin(ybeta);
	cda = cos(dalpha); sda = sin(dalpha);    
    
    /* calculate delta gamma */ 
	cc = cxb*cyb;
	ss = sxb*syb;
	a = cc + ss*cda;	 
	d = (cc+1)*cda + ss;
	e = (cxb+cyb)*sda;	
	
  b = sqrt(d*d+e*e);
	c = (1 + 2*cos(epsilon) - a) / b; 
	    /*printf("(%d, %.4e, %.4e, %.4e)\n",iab,gamma,dg,c);*/
	    
	re = d*cxg-e*sxg;
	im = -d*sxg-e*cxg;
    dg = -atan2(im,re); 
	
    if (c > 1.0) continue;  /* may be not necessary */
    else if (c < -1.0 + 1e-10) c = 3.1416;
    else c = acos(c);		

    ind_old = ind_buffer->used;
    buffer_set_offset(ind_buffer,ths->igamma[iab]);
    S1Grid_find_region(&ths->gamma[iab],dg,c,
		       ind_buffer);    

    /* calculate distances */
    double_buffer_reserve(dist_buffer,ind_buffer->used);
    for (j=ind_old;j<ind_buffer->used;j++){ /*cos omega*/
     
      /*printf("%.4e ",180/3.14*dg);*/
      dg2 = MOD0(ths->gamma_large[ind_buffer->data[j]]-dg,
		 ths->gamma[iab].p);
      /*printf("%.4e\n ",180/3.14*dg2);
	printf("%.4e ",180/3.14*acos((-1.0 + a + b *  cos(dg2))/2));*/
      dist_buffer->data[j] = cos(0.5*acos(MIN(1,MAX(-1,
					  (-1.0 + a + b *  cos(dg2))/2
						    ))));
      /*printf("%.4e ",180/3.14*acos((-1.0 + a + b *  cos(dg2))/2));*/
      /*printf("%.4e %.4e %.4e \n",a,b,dg);*/
    }
  }
}
