#include <mex.h> 
#include <matrix.h> 

#define _USE_MATH_DEFINES
#include <math.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "binghamNormalizationConstant.h"

/*
 * Igor Gilitschenski, Gerhard Kurz, Simon J. Julier, Uwe D. Hanebeck,
 * Efficient Bingham Filtering based on Saddlepoint Approximations
 * Proceedings of the 2014 IEEE International Conference on Multisensor Fusion 
 * and Information Integration (MFI 2014), Beijing, China, September 2014.
*/

void xi2CGFDeriv(double t, int dim, double *la, double* res, int derriv);

int compareDouble (const void * a, const void * b);
double findRootNewton(int dim, double *la);
double *findMultipleRootsNewton(int dim, double *la);

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *eigval; // Eigenvalues of the matrix.
    size_t m,n;
    double *resultNC, *resultDeriv;
    
    
    /* Check argument count */
    if (nrhs != 1 ) { 
		mexErrMsgTxt("requires 1 input argument."); 
	} else if (nlhs > 2) { 
		mexErrMsgTxt("returns at most two values."); 
	} 
    
  	/* Get arguments from MATLAB */ 
	eigval = mxGetPr(prhs[0]); // Vector containing la.
	m = mxGetM(prhs[0]); //rows of la
    n = mxGetN(prhs[0]); //columns of la
    
    /* Check argument dimensionality */
    if(n != 1 || m==0) {
        mexErrMsgTxt("column vector expected.");
    }
    
      
    plhs[0] = mxCreateDoubleMatrix(3,1,mxREAL);
    resultNC = mxGetPr(plhs[0]);
    
    if(nlhs == 1)        
        resultDeriv = 0;
    else { 
        
        // Compute derivatives
        plhs[1] = mxCreateDoubleMatrix(3,m,mxREAL);
        resultDeriv = mxGetPr(plhs[1]);
    }
    
    binghamNormalizationConstant((int)m, eigval, resultNC, resultDeriv);
}

