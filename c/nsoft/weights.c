#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <util.h>
#include <weights.h>

/**returns the nodes for the z-axis*/
double getEulerNodes(int bw, int j)
{
return PI*j/(bw);
}

/**returns weights used in the SOFT algorithm*/
double *getWeights(int bw)
{
int j,k;
double sum;
double *weights= (double*) malloc((2*bw)*sizeof(double));

for  (j=0;j<2*bw;j++)
{
sum=0.;
	for (k=0;k<bw;k++)
	{
	sum=sum+(1./(2.*k+1.))*sin((PI/(4.*bw))*(2.*j+1.)*(2.*k+1.));
	}

weights[j]=2.0/bw * sin(PI*(2*j+1)/(4*bw))*sum;
}

return weights;
}

double getNodes(int bw,int j)
{
return PI*(2.0*j+1.0)/(4*bw);
}


/**returns Clenshaw Curtis weights*/
double *getCCWeights(int bw)
{
int j,k;
double epsilon[bw+1];
double sum;
double *weights= (double*) malloc((2*bw+1)*sizeof(double));

epsilon[0]=0.5;
epsilon[bw]=0.5;
for (j=1;j<bw;j++) epsilon[j]=1.;

for (j=0;j<=2*bw;j++)
{
sum=0.;
	for (k=0;k<=bw;k++)
	{
	sum=sum+(epsilon[k]*((-2.)/(4.*k*k-1.))*cos((j*k*PI)/(bw)));
	}

weights[j]=(1./bw)*sum;
}

weights[0]=weights[0]/2.;
weights[2*bw]=weights[2*bw]/2.;

return weights;
}

double getCCNodes(int bw,int j)
{
return (PI*j)/(2.*bw);
}


