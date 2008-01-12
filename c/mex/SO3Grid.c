#include "S2Grid.c"



typedef struct SO3Grid_ {
  
  S2Grid alphabeta;
  S1Grid *gamma;
  double *gamma_large;
  int n, nalphabeta, ngamma;

  buffer alphabeta_buffer;

} SO3Grid;


void SO3Grid_init(SO3Grid ths[],
		  double alpha[],
		  double beta[],
		  double gamma[],
		  double sgamma[],
		  int nbeta,
		  int ialphabeta[],
		  int ngamma,
		  double palpha,
		  double pgamma)
{
  int i;
  /*printf("[%d,%d]",nalphabeta,ngamma);*/

  ths->nalphabeta = ialphabeta[nbeta];
  ths->ngamma = ngamma / ths->nalphabeta;
  ths->n = ngamma;

  S2Grid_init(&ths->alphabeta, alpha, beta, nbeta, ialphabeta, palpha);

  ths->gamma = (S1Grid*) mxCalloc(ths->nalphabeta,sizeof(S1Grid));
  for (i=0;i<ths->nalphabeta;i++)
    S1Grid_init(&ths->gamma[i],&gamma[i*ths->ngamma],
		ths->ngamma,sgamma[i],pgamma);
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

int SO3Grid_find(SO3Grid ths[],
		 double alpha,
		 double beta,
		 double gamma)
{

  int iab;
  double cxa,cxb,cxg,sxa,sxb,sxg;
  double yalpha,ybeta,dalpha;
  double cya,cyb,cyg,sya,syb,syg;
  double re,im,dg;

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxa = cos(alpha); cxb = cos(beta); 
  sxa = sin(alpha); sxb = sin(beta); 

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
    
  /* calculate delta gamma */
  re = 0.5*cxb*cyb*(cos(dalpha-gamma)+cos(-dalpha-gamma)) + 
    cxg * (sxb*syb + cos(dalpha)) - 
    (cxb+cyb)*sin(dalpha) * sxg;
  im = 0.5*cxb*cyb*(sin(dalpha-gamma)+sin(-dalpha-gamma)) -
    sxg * (sxb*syb + cos(dalpha)) -
    (cxb+cyb)*sin(dalpha) * cxg;
    
  dg = -atan2(im,re);

  return iab*ths->ngamma + S1Grid_find(&ths->gamma[iab],dg);    

}

void SO3Grid_find_region(SO3Grid ths[],
			 double alpha,
			 double beta,
			 double gamma,
			 double epsilon,
			 buffer ind_buffer[])
{

  int i, iab, j, ind_old;
  double cxa,cxb,cxg,sxa,sxb,sxg;
  double yalpha,ybeta,dalpha;
  double cya,cyb,cyg,sya,syb,syg;
  double a,b,re,im,dg,dg2;

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxa = cos(alpha); cxb = cos(beta); 
  sxa = sin(alpha); sxb = sin(beta); 

  /* search alphabeta */
  buffer_reset(&ths->alphabeta_buffer);
  S2Grid_find_region(&ths->alphabeta,beta,alpha,
		     epsilon,&ths->alphabeta_buffer);

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
    
    /* calculate delta gamma */
    a = cxb*cyb + sxb*syb*cos(dalpha);
    re = 0.5*cxb*cyb*(cos(dalpha-gamma)+cos(-dalpha-gamma)) + 
      cxg * (sxb*syb + cos(dalpha)) - 
      (cxb+cyb)*sin(dalpha) * sxg;
    im = 0.5*cxb*cyb*(sin(dalpha-gamma)+sin(-dalpha-gamma)) -
      sxg * (sxb*syb + cos(dalpha)) -
      (cxb+cyb)*sin(dalpha) * cxg;
    
    b = sqrt(re*re+im*im);
    if (a > 1.0) continue;
    if (a < -1.0) epsilon = 6;

    dg = -atan2(im,re);

    ind_old = ind_buffer->used;
    buffer_set_offset(ind_buffer,iab*ths->ngamma);
    S1Grid_find_region(&ths->gamma[iab],dg,acos((1 + 2*cos(epsilon) - a) / b),
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
  double cxa,cxb,cxg,sxa,sxb,sxg;
  double yalpha,ybeta,dalpha;
  double cya,cyb,cyg,sya,syb,syg;
  double a,b,re,im,dg,dg2;

  alpha = MOD(alpha,ths->alphabeta.rho[0].p);

  /* calculate sin and cos */
  cxa = cos(alpha); cxb = cos(beta); 
  sxa = sin(alpha); sxb = sin(beta);

  /* search alphabeta */
  buffer_reset(&ths->alphabeta_buffer);
  S2Grid_find_region(&ths->alphabeta,beta,alpha,
		     epsilon,&ths->alphabeta_buffer);

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
    
    /* calculate delta gamma */
    a = cxb*cyb + sxb*syb*cos(dalpha);
    re = 0.5*cxb*cyb*(cos(dalpha-gamma)+cos(-dalpha-gamma)) + 
      cxg * (sxb*syb + cos(dalpha)) - 
      (cxb+cyb)*sin(dalpha) * sxg;
    im = 0.5*cxb*cyb*(sin(dalpha-gamma)+sin(-dalpha-gamma)) -
      sxg * (sxb*syb + cos(dalpha)) -
      (cxb+cyb)*sin(dalpha) * cxg;
    
    b = sqrt(re*re+im*im);
    if (a > 1.0) continue;
    if (a < -1.0) epsilon = 6;

    dg = -atan2(im,re);

    ind_old = ind_buffer->used;
    buffer_set_offset(ind_buffer,iab*ths->ngamma);
    S1Grid_find_region(&ths->gamma[iab],dg,acos((1 + 2*cos(epsilon) - a) / b),
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
    }
  }
}
