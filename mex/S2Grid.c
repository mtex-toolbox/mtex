#include "S1Grid.c"


typedef struct S2Grid_ {

  S1Grid theta;
  int ntheta;  
  S1Grid *rho;
  int *irho;
  int n;
  double *theta_large;
  double *rho_large;
  buffer theta_buffer;

} S2Grid;


void S2Grid_init(S2Grid ths[],
		 double rho[],
		 double theta[],
		 int ntheta,
		 int irho[],
		 double prho)
{
  int i,j;
  
  S1Grid_init(&ths->theta, theta, ntheta,0.0,0.0);  
  ths->irho = irho;
  ths->ntheta = ntheta;
  ths->n = ths->irho[ntheta];
  ths->rho = (S1Grid*) mxCalloc(ths->ntheta,sizeof(S1Grid));
  for (i=0;i<ths->ntheta;i++)
    S1Grid_init(&ths->rho[i],&rho[irho[i]],irho[i+1]-irho[i],0.0,prho);

  buffer_init(&ths->theta_buffer,ntheta);

  ths->rho_large = rho;
  ths->theta_large = (double*) mxCalloc(ths->n,sizeof(double));
  for (j=0;j<ntheta;j++)
    for (i=irho[j];i<irho[j+1];i++)
      ths->theta_large[i]=theta[j];

  /*print_double(ths->theta_large,ths->n);*/
}

void S2Grid_print(S2Grid ths[])
{
  printf("theta:\n");
  S1Grid_print(&ths->theta);
  printf("rho:\n");
  S1Grid_print(&ths->rho[ths->ntheta-1]);
  printf("itheta: ");print_int(ths->irho,ths->ntheta+1);
  printf("n: %d\n",ths->n);
		       
}

void S2Grid_finalize(S2Grid ths[])
{
  int i;
  for (i=0;i < ths->ntheta;i++)
    S1Grid_finalize(&ths->rho[i]);
  mxFree(ths->rho);
  mxFree(ths->theta_large);
  buffer_finalize(&ths->theta_buffer);
  
}

void S2Grid_get(S2Grid ths[], int theta[], int rho[])
{

}

int S2Grid_find(S2Grid ths[],
		 double theta,
		 double rho)
{
  int itheta;

  /* search theta */
  buffer_reset(&ths->theta_buffer);
  itheta = S1Grid_find(&ths->theta,theta);

  /* search rho */  
  return ths->irho[itheta] + S1Grid_find(&ths->rho[itheta],rho);    
}


void S2Grid_find_region(S2Grid ths[],
			double theta,
			double rho,
			double e,
			buffer ind_buffer[])
{
  int i,itheta;
  double cs,ss,ct,st,ce;
  
  ce = cos(e);
  ct = cos(theta);
  st = sin(theta);
  
  /* search theta */
  buffer_reset(&ths->theta_buffer);
  S1Grid_find_region(&ths->theta,theta,e,&ths->theta_buffer);

  /* search rho */
  for (i=0;i<ths->theta_buffer.used;i++) {

    itheta = ths->theta_buffer.data[i];
    buffer_set_offset(ind_buffer,ths->irho[itheta]);
    /*printf("iytheta: %d \n",iytheta[itheta]);*/

    /* calculate new distances */
    cs = ct*cos(ths->theta.x[itheta]);
    ss = st*sin(ths->theta.x[itheta]);  

    if (ss < 0.0001 || (ce-cs)/ss < -0.9999)   
      
      /* close to north-pole -> all points */
      buffer_append(ind_buffer,0,ths->rho[itheta].n-1);
    
    else if  (cs + ss > ce)
      /* search rho */
      S1Grid_find_region(&ths->rho[itheta],rho,
			 acos((ce-cs)/ss),ind_buffer);    
  }
}
