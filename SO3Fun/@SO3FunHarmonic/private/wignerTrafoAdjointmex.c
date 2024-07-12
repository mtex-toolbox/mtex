/*=========================================================================
 * wignerTrafoAdjointmex.c - quadrature of SO3FunHarmonic
 * 
 * The input is a 3-tensor, that is received by the inverse nfft(3) respecting
 * the Euler angles of evaluations of a SO(3) function (F).
 * We calculate as output the corresponding SO(3) fourier coefficient vector 
 * (fhat) of this function F.
 * Therefore we use symmetry properties of F to calculate only a part of symmetrical
 * SO(3) Fourier coefficients and to speed up the algorithm. The following 
 * symmetry properties are implemented:
 * 1) Possibly the size of the input was made even in any dimension by
 * adding zeros in front. That was necessary since inverse nfft was done for 
 * indices -N-1 : N but the values were given for indices -N:N.
 * 2) If F is a real valued function, the SO(3) Fourier coefficients satisfy
 * the symmetry property
 *                     fhat(n,k,l) = conj(fhat(n,-k,-l)). 
 * 3) If F is an antipodal function, the SO(3) Fourier coefficients satisfy
 * the symmetry property
 *                     fhat(n,k,l) = fhat(n,-l,-k). 
 * 4) Similarly an r-fold symmetry axis along the Z-axis in right or left 
 * symmetry implies that the SO(3) Fourier coefficients satisfy
 *                    fhat(n,k,l) = 0   if k mod r is not 0
 * or
 *                    fhat(n,k,l) = 0   if l mod r is not 0.
 * Moreover an 2-fold symmetry along Y-axis yields 
 *            fhat(n,k,l) = (-1)^n fhat(n,-k,l)
 * for right symmetry and
 *            fhat(n,k,l) = (-1)^n fhat(n,k,-l)
 * in case of left symmetry.
 *
 *
 * For the calculation of fhat we need Wigner-d matrices with Euler angle
 * beta = pi/2. From symmetry properties of this Wigner-d matrices we get
 *       (-1)^(k+l) * d^n(l,k) = d^n(k,l) = (-1)^(n+k+l) * d^n(k,-l).
 * We use this to speed up the calculation of fhat.
 * 
 * Syntax
 *   flags = 2^0+2^2+2^4;
 *   sym_axis = [1,2,2,1];
 *   fhat = wignerTrafoAdjointmex(N,ghat,flags,sym_axis);
 * 
 * Input
 *  N        - bandwidth
 *  ghat     - matrix of fourier transformed function evaluations on ClenshawCurtis grid
 *  flags    - 2^0 -> use L_2-normalized Wigner-D functions
 *             2^1 -> use input of even size            (not implemented yet)
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> antipodal
 *             2^4 -> use right and left symmetry
 *  sym_axis - vector [SRight-Y,SRight-Z,SLeft-Y,SLeft-Z] where SRight-Y,SLeft-Y are in {1,2} and 
 *             SRight-Z,SLeft-Z are in {1,2,3,4,6} and describes the countability of the symmetry axis
 *
 * Output
 *  fhat - SO(3) Fourier coefficient vector
 *
 *
 * This is a MEX-file for MATLAB.
 * 
 *=======================================================================*/

#include <mex.h>
#include <math.h>
#include <matrix.h>
#include <stdio.h>
#include <complex.h>
#include <string.h>
#ifdef _OPENMP // For parallelisation
#include <omp.h>
#endif
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_recursion_at_pi_half.c"   // use three term recurrence relation to compute Wigner-d matrices
#include "L2_normalized_WignerD_functions.c"  // use L_2-normalized Wigner-D functions by scaling the fourier coefficients



// The computational routine
static void calculate_ghat_adjoint( const mxDouble bandwidth, mxComplexDouble *ghat,
                          const int isReal, const int isAntipodal, mxDouble *sym_axis,
                          mxComplexDouble *fhat)
{

  // define usefull variables
    int k,l,j,n;                                      // running indices
    const int N = bandwidth;                          // integer bandwidth
    const int rowcol_len = (2*N+1);                   // length of a row and a column in ghat
    const int matrix_size = rowcol_len*rowcol_len;    // size of one matrix in ghat
    const int SRightY = sym_axis[0];
    const int SRightZ = sym_axis[1];
    const int SLeftY = sym_axis[2];
    const int SLeftZ = sym_axis[3];
            
  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      (*fhat).real = (*ghat).real;
      (*fhat).imag = (*ghat).imag;
      return;
    }
    
    
  // Idea: Calculate Wigner-d matrix by recurrence formula from last two
  // Wigner-d matrices. 
  // Because of symmetry only the left parts of the rows are needed.
  //       (  A  | A'  )        + (the cross) represents row and column with index 0
  //   d = ( ----+---- )        ' corresponds to flip(.,2)
  //       (  A* | A*' )        * corresponds to flip(.,1)
    // Create 3 Wigner-d matrices for recurrence relation (2 as input and 1
    // as output). Also get an auxiliary pointer to the matrices in each case.
    mxArray *D_min2 = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd_min2 = mxGetDoubles(D_min2);
    mxDouble *start_wigd_min2;
    start_wigd_min2 = wigd_min2;
    
    mxArray *D_min1 = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd_min1 = mxGetDoubles(D_min1);
    mxDouble *start_wigd_min1;
    start_wigd_min1 = wigd_min1;
    
    mxArray *D = mxCreateDoubleMatrix(2*N+1,N+1,mxREAL);
    mxDouble *wigd = mxGetDoubles(D);
    mxDouble *start_wigd;
    start_wigd = wigd;
    
    
    // Set start values for recurrence relations to compute Wigner-d matrices
    // Wigner_d(0,pi/2)
    wigd_min2[2*(N+1)*N] = 1;         // go to last column and center row of matrix
    
    // Wigner_d(1,pi/2)
    wigd_min1 += (2*N+1)*(N-1)+N;               // go to Wigner_d(1,pi/2) at matrixposition [-1,-1]
    const double sqrt_1_2 = sqrt(0.5);
    const double wigd_harmonicdegree1[3][3] = { // values of Wigner_d(1,pi/2)
                                                  {   0.5  ,-sqrt_1_2,  -0.5  },
                                                  {sqrt_1_2,     0   ,sqrt_1_2},
                                                  {  -0.5  ,-sqrt_1_2,   0.5  }};
    for (k=0; k<2; k++)
    {
      for (l= -1; l<=1; l++)
      {
        wigd_min1[l] = wigd_harmonicdegree1[l+1][k];  // fill with values
      }
      wigd_min1 += 2*N+1;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // reset pointer to matrix start
    
  // Compute fhat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining indices n > 1.
    // Create pointer that saves the position ghat(0,0,0)
    mxComplexDouble *center_ghat;
    center_ghat = ghat + N + N*rowcol_len + N*matrix_size;

  // Do step n = 0.
    // Write ghat(0,0,0) in fhat(1), since Wigner_d(0,pi/2) = 1.
    ghat = center_ghat;
    *fhat = *ghat;
    // Set pointer fhat to next harmonic degree (to the 2nd value of fhat)
    fhat ++;
    
  // Do step n = 1, without use of symmetry
    // jump to ghat(-1,0,-1)
    ghat += -matrix_size -1;

    // fill fhat with values fhat(n,k,l) = sum_{j=-n}^n ghat(k,j,l) * d^1(j,k) * d^1(j,l)
    double value;
    for (l= -1; l<= 1; l++)
    {
      for (k= -1; k<=1; k++)
      {
        for (j= -1; j<=1; j++)
        {
          value = wigd_harmonicdegree1[k+1][-j+1] * wigd_harmonicdegree1[l+1][-j+1];
          (*fhat).real += ghat[j*(2*N+1)].real* value;
          (*fhat).imag += ghat[j*(2*N+1)].imag* value;
        }
        // jump to next row
        fhat ++;
        ghat ++;
      }
      // jump to next column
      ghat += -3+matrix_size;
    }

    // Be shure N>1, otherwise STOP.
    if (N==1)
      return;
    
    
  // define some usefull variables
    const int shift_tocenterwigner = (2*N+1)*N+N;
    double pm;
    int column, L_min, L_max, K_min, K_max, K_shift, L_shift;
    mxComplexDouble *ghat2, *iter_fhat;
    mxDouble *wigk, *wigl;
    
  // define pointer that saves the position of fhat_1^(0,0)
    iter_fhat = fhat-5;

  // Do recursion for 1 < n <= N and use symmetry:
    for (n=2; n<=N; n++)
    {
      // Calculate Wigner-d matrix
      wigner_d_recursion_at_pi_half(N,n,wigd_min2,wigd_min1,wigd);
      
      // jump to the center of Wigner-d matrix
      wigd +=  shift_tocenterwigner;

      //pm = -1.0;

      // Compute fhat by adding fhat(n,k,l) = sum_{j=-n}^n ghat(k,j,l) * d^n(j,k) * d^n(j,l)
      // Use symmetry properties in Wigner-d functions:
      // fhat(n,k,l) = ghat(k,0,l)*d^n(k,0)*d^n(l,0)  +  sum_{j=1}^n (ghat(k,j,l)+(-1)^(k+l)*ghat(k,-j,l)) * d^n(k,-j)*d^n(l,-j)
      // ignore some values if - SO3FunHarmonic is real valued
      //                       - SO3FunHarmonic is antipodal
      //                       - we have right and left symmetry
        // set left and right loop bounds
        L_shift = n % SLeftZ;
        L_min = -n+L_shift;
        L_max = n-L_shift;
        if(SLeftY==2)
          L_max=0;
        K_shift = n % SRightZ;
        K_min = -n+K_shift;
        K_max = n-K_shift;
        if(SRightY==2)
          K_max=0;

        if((SRightY*SLeftY==2) && (isReal==1)) 
        {
          K_max=0;
          L_max=0;
        }
        if((SRightY*SLeftY==1) && (isReal==1) && (isAntipodal==0))
          K_max=0;

      // move pointer to fhat_n^(0,0)
      iter_fhat += (4*n*n+1);

      #pragma omp parallel for firstprivate(ghat,fhat,wigd,K_min,K_max) private(pm,wigk,wigl,ghat2,column,value)        // Parallelization
      for (l= L_min; l<=L_max; l+=SLeftZ)
      {
        if(isAntipodal==1)
        {
          if(SRightY*SLeftY==1)
          {
            K_max = -l;
            if(isReal==1)
            {
              K_min = l;
              L_max = 0;
            }
          }
          if((SRightY*SLeftY==4))
            K_min = l;
        }

        // shift pointer ghat to (K_min,0,l)
        ghat = center_ghat + K_min + l*matrix_size;
        // shift pointer fhat to fhat_n^(K_min,l)
        fhat = iter_fhat + K_min + l*(2*n+1);        

        for (k= K_min; k<=K_max; k+=SRightZ)
        {
          if((k+l)%2==0) 
            pm = 1.0;
          else
            pm = -1.0;
          // iteration for j = 0
          wigk = wigd+k;
          wigl = wigd+l;
          value = (*wigk) * (*wigl);
          (*fhat).real = (*ghat).real * value;
          (*fhat).imag = (*ghat).imag * value;
          ghat2 = ghat-rowcol_len;
          ghat += rowcol_len;
          // iteration for 0 < j <= n
          for (j= 1; j<=n; j++)
          {
            column = -j*rowcol_len;
            value = wigk[column] * wigl[column];
            (*fhat).real += ((*ghat).real + pm*(*ghat2).real) * value;
            (*fhat).imag += ((*ghat).imag + pm*(*ghat2).imag) * value;
            ghat2 -= rowcol_len;
            ghat += rowcol_len;
          }
          fhat += SRightZ;
          ghat += SRightZ -rowcol_len*(n+1);
        }
      }
      
      // permute the pointers (wigd, wigdmin1 and wigdmin2) for the next
      // recursions step for the calculation of the Wigner-d matrices.
      // Therefore the two most recently computed Wigner-d matrices are
      // used for next recursion step.
      // The other matrix will be overwritten in the next step.
      // Use wigd as exchange variable.
      wigd = start_wigd_min2;
      
      start_wigd_min2 = start_wigd_min1;
      start_wigd_min1 = start_wigd;
      start_wigd = wigd;
      
      wigd_min1 = start_wigd_min1;
      wigd_min2 = start_wigd_min2;
    }

  // free the storage of the Wigner-d matrices
    mxDestroyArray(D);
    mxDestroyArray(D_min1);
    mxDestroyArray(D_min2);

}




// The gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  
  // variable declarations
    mxDouble bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // input coefficient 3-tensor
    mxDouble input_flags = 0;
    mxDouble *sym_axis;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient vector
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:maxlhs","One output is required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notDouble","Second input argument coefficient array must be type double.");
    // check that second input argument (inCoeff) is 3-dimensional array or just one value (if N==0)
    const bool single_value = ( (mxGetM(prhs[1])==1) && (mxGetN(prhs[1])==1) && (mxGetScalar(prhs[0])==0) );
    if(  (mxGetNumberOfDimensions(prhs[1])!=3) && (!single_value)  )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:inputNotTensor","Second input argument coefficient array must be a 3-tensor.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notDouble","Third input argument flags must be a scalar double.");

    // get dimensions of the input 3-tensor
    const mwSize *dims = mxGetDimensions(prhs[1]);
    if( (dims[0]!=dims[1]) || ( mxGetN(prhs[1])!=dims[0]*dims[1]) )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:falseDim","Second input argument coefficient array needs same length in each dimension.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=4 ) )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notDouble","Fourth input argument sym_axis must be a 4x1 double vector.");

    
  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("wignerTrafoAdjointmex:notInt","First input argument must be a natural number.");
    
    // make input 3-tensor complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input 3-tensor (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // if exists, get flags of input
    if(nrhs>=3)
      input_flags = mxGetScalar(prhs[2]);
    bool flags[7];
    get_flags(input_flags,flags);

    // if exists and the flag implies we want to use right and left 
    // symmetries to speed up --> get sym_axis of input
    double s[4] = {1,1,1,1};
    if( (nrhs>=4) && (flags[4]) )
      sym_axis = mxGetDoubles(prhs[3]);
    else
      sym_axis = s;

    if( ((sym_axis[0]!=sym_axis[2]) || (sym_axis[1]!=sym_axis[3])) && flags[3] )
      mexErrMsgIdAndTxt( "wignerTrafoAdjointmex:notAntipodal","ODF can only be antipodal if both symmetries coincide!");

    
    const int isReal = flags[2];
    const int isAntipodal = flags[3];


  // create output data
    const int deg2dim = (bandwidth+1)*(2*bandwidth+1)*(2*bandwidth+3)/3;
    plhs[0] = mxCreateNumericMatrix(deg2dim, 1, mxDOUBLE_CLASS, mxCOMPLEX);

    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);


  // call the computational routine
    calculate_ghat_adjoint(bandwidth,inCoeff,isReal,isAntipodal,sym_axis,outFourierCoeff);

  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_WignerD_functions(bandwidth,outFourierCoeff);

  // free the storage
  mxDestroyArray(zeiger);

}
