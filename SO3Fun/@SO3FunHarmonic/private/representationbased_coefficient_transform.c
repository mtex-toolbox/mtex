/*=========================================================================
 * representationbased_coefficient_transform.c - eval of SO3FunHarmonic
 * 
 * The inputs are the fourier coefficients (fhat) of the harmonic 
 * representation of a SO(3) function SO3F and the bandwidth (N).
 * This harmonic representation will be transformed to a FFT(3) in terms
 * of Euler angles.
 * We calculate as output the coresponding fourier coefficient matrix.
 * Therefore we use symmetry properties of SO3F to calculate only a part of
 * symmetrical SO(3) Fourier coefficients and to speed up the algorithm. 
 * The following symmetry properties are implemented:
 * 1) For the calculation of ghat we need Wigner-d matrices with Euler angle
 * beta = pi/2. There are a lot of symmetry properties in this Wigner-d
 * matrices. We use this to compute the Wigner-d's faster.
 * From the symmetry properties of the Wigner-d functions we get
 *                ghat(l,j,k) = (-1)^(k+l) ghat(l,-j,k).
 * 2) If SO3F is a real valued function, the SO(3) Fourier coefficients 
 * satisfy the symmetry property
 *                     fhat(n,k,l) = conj(fhat(n,-k,-l))
 * where conj denotes the conjugate complex. Hence we get
 *            ghat(k,j,l) = (-1)^(k+l) * conj(ghat(-k,j,-l)).
 * Moreover we can half the following FFT(3) to (-N:N)x(-N:N)x(0:N). 
 * Therefore ghat(:,:,0) has to be halved.
 * 3) If SO3F is an antipodal function, the SO(3) Fourier coefficients 
 * satisfy the symmetry property
 *                   fhat(n,k,l) = fhat(n,-l,-k).
 * Hence we have
 *              ghat(k,j,l) = (-1)^(k+l) * ghat(-l,j,-k).
 * 4) Similarly an r-fold symmetry axis along the Z-axis in right or left 
 * symmetry implies that the SO(3) Fourier coefficients satisfy
 *              fhat(n,k,l) = 0   if k mod r is not 0
 * or
 *              fhat(n,k,l) = 0   if l mod r is not 0.
 * Hence we get
 *              ghat(k,j,l) = 0   if k mod r is not 0
 * and
 *              ghat(k,j,l) = 0   if l mod r is not 0.
 * 5) Moreover an 2-fold symmetry along Y-axis yields 
 *            fhat(n,k,l) = (-1)^n fhat(n,-k,l)
 * for right symmetry and
 *            fhat(n,k,l) = (-1)^n fhat(n,k,-l)
 * in case of left symmetry.
 * Hence we have
 *            ghat(k,j,l) = (-1)^(k+j) * ghat(-k,j,l)
 * and
 *            ghat(k,j,l) = (-1)^(l+j) * ghat(k,j,-l).
 *
 * It is also possible to calculate ghat with even size in any dimension by
 * using the flag 2^1. Therefore zeros are added in front of the output 
 * 3-tensor. That is necessary since the nfft is done for indices -N-1 : N 
 * but the values are given for indices -N:N.
 *
 *
 * Syntax
 *   flags = 2^0+2^2+2^4;
 *   sym_axis = [1,2,2,1];
 *   ghat = representationbased_coefficient_transform(N,fhat,flags,sym_axis);
 * 
 * Input
 *  N        - bandwidth
 *  fhat     - SO(3) Fourier coefficient vector
 *  flags    - double where:
 *             2^0 -> use L_2-normalized Wigner-D functions
 *             2^1 -> make size of result even
 *             2^2 -> fhat are the fourier coefficients of a real valued function
 *             2^3 -> antipodal            (not implemented yet)
 *             2^4 -> use right and left symmetry
 *  sym_axis - vector [SRight-Y,SRight-Z,SLeft-Y,SLeft-Z] where SRight-Y,SLeft-Y are in {1,2} and 
 *             SRight-Z,SLeft-Z are in {1,2,3,4,6} and describes the countability of the symmetry axis
 *
 * Output
 *  ghat - Wigner transformed SO(3) Fourier coefficients
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
#include "get_flags.c"  // transform number which includes the flags to boolean vector
#include "wigner_d_recursion_at_pi_half.c"   // use three term recurrence relation to compute Wigner-d matrices
#include "L2_normalized_WignerD_functions.c"  // use L_2-normalized Wigner-D functions by scaling the fourier coefficients



// The computational routine
static void calculate_ghat( const mxDouble bandwidth, mxComplexDouble *fhat,
                            const int makeEven, const int isReal, const int isAntipodal, 
                            mxDouble *sym_axis, mxComplexDouble *ghat, const mwSize nrows )
{

  // define usefull variables
    int k,l,j,n;                                      // running indices
    const int N = bandwidth;                          // integer bandwidth
    const int rowcol_len = (2*N+1+makeEven);          // length of a row and a column [ ghat(1,:,1) and ghat(:,1,1)]
    const int matrix_size = rowcol_len*rowcol_len;    // size of one matrix [ ghat(:,:,1) ]
    const int SRightY = sym_axis[0];                  // {1,2} - fold rotation around Y-axis in right symmetry
    const int SRightZ = sym_axis[1];                  // {1,2,3,4,6} - fold rotation around Z-axis in right symmetry
    const int SLeftY = sym_axis[2];                   // {1,2} - fold rotation around Y-axis in left symmetry
    const int SLeftZ = sym_axis[3];                   // {1,2,3,4,6} - fold rotation around Z-axis in left symmetry
    
    
  // Be shure N>0. Otherwise return the trivial solution.
    if(N==0)
    {
      ghat[0].real = fhat[0].real/(1+isReal);
      ghat[0].imag = fhat[0].imag/(1+isReal);
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
      for (l = -1; l<=1; l++)
      {
        wigd_min1[l] = wigd_harmonicdegree1[l+1][k];  // fill with values
      }
      wigd_min1 += 2*N+1;                             // go to next column
    }
    wigd_min1 = start_wigd_min1;                      // reset pointer to matrix start
    

  // Compute ghat by iterating over harmonic degree n of Wigner-d matrices
  // in outermost loop. Start with n=0 and n=1 manually and use a loop for
  // the remaining indices n > 1, except the last one. It is sufficient to
  // compute only one of the symmetric values in ghat.
  // Do the last iteration n=N seperately and use symmetry in 3rd dimension 
  // of ghat to fill the symmetric values.
    // Create pointers for help. One saves the starting position of ghat
    // and the other one saves the starting position of fhat in current
    // iteration of harmonic degree n.
    mxComplexDouble *start_ghat;
    start_ghat = ghat;
    mxComplexDouble *iter_fhat;
    

  // Do recursion for n = 0.
    // Write first value of fhat in ghat(0,0,0) , since Wigner_d(0,pi/2)=1.
    ghat[(1-isReal)*matrix_size*N + rowcol_len*N + N] = *fhat;
    // Set pointer fhat to next harmonic degree (to the 2nd value of fhat)
    fhat ++;
    
  
  // Do recursion for n = 1.
    // jump to ghat(-1,-1,-1)
    ghat += (1-isReal)*matrix_size*(N-1) + rowcol_len*(N-1) + (N-1);
    // if ghat is halfsized skip 3 values of fhat
    fhat += 3*isReal;
    iter_fhat = fhat;
    // fill ghat with values := fhat(1,k,l) * d^1(j,k) * d^1(j,l)
    double value;
    for (j= -1; j<= 1; j++)
    {
      for (l= -1+isReal; l<=1; l++)
      {
        for (k= -1; k<=1; k++)
        {
          value = wigd_harmonicdegree1[k+1][-j+1] * wigd_harmonicdegree1[l+1][-j+1];
          ghat[k+1].real += fhat[k+1].real* value;
          ghat[k+1].imag += fhat[k+1].imag* value;
        }
        // jump to next matrix (3rd dimension)
        ghat += matrix_size;
        fhat += 3;
      }
      // jump to next column
      ghat += -matrix_size*(3-isReal)+rowcol_len;
      // reset pointer fhat
      fhat = iter_fhat;
    }
    // Set pointer fhat to next harmonic degree (to the 11th value of fhat)
    fhat += 9 - 3*isReal;
    // reset pointer ghat to ghat(-N,-N,-N)
    ghat = start_ghat;
    
    
    // Be shure N>1, otherwise STOP.
    if (N==1)
    {
      if(isReal==1) // possibly we have to half the values in ghat(:,:,0)
      {
        for (j=0; j<3; j++)
        {
          for (k=0; k<3; k++)
          {
            ghat[k].real = ghat[k].real/2;
            ghat[k].imag = ghat[k].imag/2;
          }
          // jump to next column
          ghat += rowcol_len;
        }
      }
      
      return;
    }
    
    
    // define some usefull variables
    const int shift_tocenterwigner = (2*N+1)*N+N;
    int L_min, L_max, K_min, K_max, K_shift, L_shift;


  // Do recursion for 1 < n < N:
    for (n=2; n<N; n++)
    {

      // Calculate Wigner-d matrix
      wigner_d_recursion_at_pi_half(N,n,wigd_min2,wigd_min1,wigd);
      
      // jump to the center of Wigner-d matrix
      wigd +=  shift_tocenterwigner;
     
      
      // Compute ghat by adding over all summands of current harmonic 
      // degree n. Therefore it is sufficient to compute ghat only for 
      // j>=0, since
      //             ghat(k,j,l) = (-1)^(k+l) * ghat(k,-j,l).
      // Moreover we have additional symmetry properties if 
      //    - SO3FunHarmonic is real valued
      //    - SO3FunHarmonic is antipodal
      //    - SO3FunHarmonic has non trivial right and left symmetry
      // We use this to speed up by only computing one of the symmetrical 
      // coefficients. Hence we set the left and right loop bounds:
      L_shift = n % SLeftZ;
      L_min = -n+L_shift;
      L_max = n-L_shift;
      if(SLeftY==2)
        L_min=0;
      K_shift = n % SRightZ;
      K_min = -n+K_shift;
      K_max = n-K_shift;
      if(SRightY==2)
        K_min=0;
      if((SRightY*SLeftY==2) && (isReal==1)) 
      {
        K_min=0;
        L_min=0;
      }
      if((SRightY*SLeftY==1) && (isReal==1) && (isAntipodal==0))
        L_min=0;


      // shift pointer ghat to ghat(0,0,0) if F is real valued and to
      // ghat(0,0,-n) otherwise (if ghat is fullsized matrix) 
      ghat += (1-isReal)*matrix_size*(N+L_min) + rowcol_len*N + N;
      // Set pointer of fhat to the central value fhat(n,0,-n) or fhat(n,0,0) 
      // and save this position for further iterations
      fhat += n + (L_min+n)*(2*n+1) ;
      iter_fhat = fhat;


      // Iteration:
      // The Wigner-d functions satisfy the symmetry property
      //          d_n(j,k)*d_n(j,l) = d_n(k,-j)*d_n(l,-j)
      // in MTEX. We use this in the following.
      for (j=0; j<=n; j++)
      {
        for (l= L_min; l<=L_max; l+=SLeftZ)
        {
          for (k= K_min; k<=K_max; k+=SRightZ)
          {
            // compute value
            value = wigd[k]*wigd[l];
            
            // set value
            ghat[k].real += fhat[k].real*value;
            ghat[k].imag += fhat[k].imag*value;

          }
          // jump to next matrix (along 3rd dimension)
          ghat += SLeftZ*matrix_size;
          fhat += SLeftZ*(2*n+1);
        }
        // reset pointer fhat
        fhat = iter_fhat;
        // jump to next column
        ghat += -matrix_size*(L_max-L_min+SLeftZ) + rowcol_len;
        // use next column of Wigner-d matrix
        wigd -= 2*N+1;
      }
      
      // reset pointer ghat to ghat(-N,-N,0) if F is real valued and 
      // ghat(-N,-N,-N) otherwise [if ghat is fullsized]
      ghat = start_ghat;
      // Set pointer fhat to first value in next harmonic degree
      fhat += -n + (2*n+1)*(n+1-L_min);

      // permute the pointers (wigd, wigdmin1 and wigdmin2) for the next
      // recursions step for the calculation of the Wigner-d matrices.
      // Therefore the two most recently computed Wigner-d matrices are
      // preserved for next recursion step.
      // The other matrix will be overwritten in the next step.
      // Use wigd as exchange variable.
      wigd = start_wigd_min2;
      
      start_wigd_min2 = start_wigd_min1;
      start_wigd_min1 = start_wigd;
      start_wigd = wigd;
      
      wigd_min1 = start_wigd_min1;
      wigd_min2 = start_wigd_min2;
    }
    



  // Do step for n=N and set symmetric values.
    // define pointer for j>0 which belongs to the symmetric values of
    // the previous pointer.
    mxComplexDouble *ghatMinusJ;

    // Calculate Wigner-d matrix
    wigner_d_recursion_at_pi_half(N,N,wigd_min2,wigd_min1,wigd);
      
    // jump to the center of the Wigner-d matrix
    wigd +=  shift_tocenterwigner;
      
    // Compute ghat by adding over all summands of current harmonic 
    // degree N.
    // We use the symmetry properties to set the symmetrical coefficients. 
    // First we set the left and right loop bounds:
    L_shift = N % SLeftZ;
    L_min = -N+L_shift;
    L_max = N-L_shift;
    if(SLeftY==2)
      L_min=0;
    K_shift = N % SRightZ;
    K_min = -N+K_shift;
    K_max = N-K_shift;
    if(SRightY==2)
      K_min=0;
    if((SRightY*SLeftY==2) && (isReal==1)) 
    {
      K_min=0;
      L_min=0;
    }
    if((SRightY*SLeftY==1) && (isReal==1))
      L_min=0;


    // shift pointer ghat to ghat(0,0,0) if F is real valued and to
    // ghat(0,0,-n) otherwise (if ghat is fullsized matrix) 
    ghat += (1-isReal)*matrix_size*(N+L_min) + rowcol_len*N + N;
    ghatMinusJ = ghat;
    // Set pointer of fhat to the central value fhat(n,0,-n) or fhat(n,0,0) 
    // and save this position for further iterations
    fhat += N + (L_min+N)*(2*N+1) ;
    iter_fhat = fhat;

    // define variables for setting the symmetric values
    bool jIsNot0;
    bool lIs0_and_isReal, LminIs0_and_NotisReal;
    double vzkl, vzkj, vzlj;
    double rsol, isol;
    int ind;

    // Iteration:
    // The Wigner-d functions satisfy the symmetry property
    //          d_n(j,k)*d_n(j,l) = d_n(k,-j)*d_n(l,-j)
    // in MTEX. We use this in the following.
    for (j=0; j<=N; j++)
    {
      jIsNot0 = (j!=0);
      for (l= L_min; l<=L_max; l+=SLeftZ)
      {
        LminIs0_and_NotisReal = L_min==0 && !isReal && l!=0;
        lIs0_and_isReal = ((l==0) && isReal);
        vzlj = -2*abs((l+j) % 2) + 1;

        for (k= K_min; k<=K_max; k+=SRightZ)
        {
          vzkj = -2*abs((k+j) % 2) + 1;
          vzkl = -2*abs((k+l) % 2) + 1;
          
          // compute value
          value = wigd[k]*wigd[l];
            
          // set values for j>=0
          ghat[k].real += fhat[k].real*value;
          ghat[k].imag += fhat[k].imag*value;

          // save ghat
          rsol = ghat[k].real;
          isol = ghat[k].imag;

          // half the values of ghat(:,:,0) if F is real valued
          if(lIs0_and_isReal)
          {
            rsol = 0.5*rsol;
            isol = 0.5*isol;
            ghat[k].real = rsol;
            ghat[k].imag = isol;
          }

          // Fill values for j<0 by symmetry property
          if(jIsNot0)
          {
            ghatMinusJ[k].real = vzkl*rsol;
            ghatMinusJ[k].imag = vzkl*isol;
          }

          // Fill values for k<0 by symmetry property if K_min=0.
          if(K_min==0 && k!=0 )
          {
            if(SRightY==1)    // isReal && SLeftY==2 && SRightY==1    --> conjugate complex
              isol = -isol;
            ghat[-k].real = vzkj*rsol;
            ghat[-k].imag = vzkj*isol;
            if(jIsNot0)
            {
              ghatMinusJ[-k].real = vzlj*rsol;
              ghatMinusJ[-k].imag = vzlj*isol;
            }
          }

          // Fill values for l<0 by symmetry properties
          if(LminIs0_and_NotisReal) // SLeftY==2 && !isReal
          {
            ind = k-2*l*matrix_size;
            ghat[ind].real = vzlj*rsol;
            ghat[ind].imag = vzlj*isol;
            if(jIsNot0)
            {
              ghatMinusJ[ind].real = vzkj*rsol;
              ghatMinusJ[ind].imag = vzkj*isol;
            }
            if(SRightY==2) // [SLeftY=SRightY=2 & !isReal] needs additionaly to the above the following
            {
              ind = -k-2*l*matrix_size;
              ghat[ind].real = vzkl*rsol;
              ghat[ind].imag = vzkl*isol;
              if(jIsNot0)
              {
                ghatMinusJ[ind].real = rsol;
                ghatMinusJ[ind].imag = isol;
              }
            }
          }
         
        }
        // jump to next matrix (along 3rd dimension)
        ghat += SLeftZ*matrix_size;
        ghatMinusJ += SLeftZ*matrix_size;
        fhat += SLeftZ*(2*N+1);
      }
      // reset pointer fhat
      fhat = iter_fhat;
      // jump to next column
      ghat += -matrix_size*(L_max-L_min+SLeftZ) + rowcol_len;
      ghatMinusJ += -matrix_size*(L_max-L_min+SLeftZ) - rowcol_len;
      // use next column of Wigner-d matrix
      wigd -= 2*N+1;
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
    int bandwidth;               // input bandwidth
    mxComplexDouble *inCoeff;         // nrows x 1 input coefficient vector
    size_t nrows;                     // size of inCoeff
    mxDouble input_flags = 0;
    mxDouble *sym_axis;
    mxComplexDouble *outFourierCoeff; // output fourier coefficient matrix
    
    
  // check data types
    // check for 2 input arguments (inCoeff & bandwith)
    if(nrhs<2)
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:invalidNumInputs","More inputs are required.");
    // check for 1 output argument (outFourierCoeff)
    if(nlhs!=1)
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:maxlhs","One output required.");
    
    // make sure the first input argument (bandwidth) is double scalar
    if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1 )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notDouble","First input argument bandwidth must be a scalar double.");
    
    // make sure the second input argument (inCoeff) is type double
    if(  !mxIsComplex(prhs[1]) && !mxIsDouble(prhs[1]) )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notDouble","Second input argument coefficient vector must be type double.");
    // check that number of columns in second input argument (inCoeff) is 1
    if(mxGetN(prhs[1])!=1)
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:inputNotVector","Second input argument coefficient vector must be a row vector.");
    
    // make sure the third input argument (input_flags) is double scalar (if existing)
    if( (nrhs>=3) && ( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1 ) )
      mexErrMsgIdAndTxt( "representationbased_coefficient_transform:notDouble","Third input argument flags must be a scalar double.");

    // make sure the fourth input argument (sym_axis) is double (if existing)
    if( (nrhs>=4) && ( !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3])!=4 ) )
      mexErrMsgIdAndTxt( "representationbased_coefficient_transform:notDouble","Fourth input argument sym_axis must be a 4x1 double vector.");


  // read input data
    // get the value of the scalar input (bandwidth)
    bandwidth = mxGetScalar(prhs[0]);
    
    // check whether bandwidth is natural number
    if( ((round(bandwidth)-bandwidth)!=0) || (bandwidth<0) )
      mexErrMsgIdAndTxt("representationbased_coefficient_transform:notInt","First input argument must be a natural number.");
    
    // make input matrix complex
    mxArray *zeiger = mxDuplicateArray(prhs[1]);
    if(mxMakeArrayComplex(zeiger)) {}
    
    // create a pointer to the data in the input vector (inCoeff)
    inCoeff = mxGetComplexDoubles(zeiger);
    
    // get dimensions of the input vector
    nrows = mxGetM(prhs[1]);
    
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
      mexErrMsgIdAndTxt( "representationbased_coefficient_transform:notAntipodal","ODF can only be antipodal if both symmetries coincide!");


    const int makeEven = flags[1];
    const int isReal = flags[2];
    const int isAntipodal = flags[3];

  
  // define length of the 3 dimensions of ghat
    // If f is a real valued function, then half size in 3rd dimension of
    // ghat is sufficient. Sometimes it is necessary to add zeros in some
    // dimensions to get even size for nfft.
    mwSize dims[3];
    dims[0] = 2*bandwidth+1+makeEven;
    dims[1] = 2*bandwidth+1+makeEven;
    int start_shift;
    if (isReal == 0){
      dims[2] = 2*bandwidth+1+makeEven;
      start_shift = makeEven*(dims[0]*dims[1] + dims[0] + 1);
    }
    else if (bandwidth % 2 == 0){
      dims[2] = bandwidth+1+makeEven;
      start_shift = makeEven*(dims[0]*dims[1] + dims[0] + 1);
    }
    else{
      dims[2] = bandwidth+1;
      start_shift = makeEven*(dims[0] + 1);
    }
    
 
  // create output data
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    
    // create a pointer to the data in the output array (outFourierCoeff)
    outFourierCoeff = mxGetComplexDoubles(plhs[0]);
    // set pointer to skip first index
    outFourierCoeff += start_shift;
    
  
  // use L2-normalize Wigner-D functions by scaling the fourier coefficients
  if(flags[0])
    L2_normalized_WignerD_functions(bandwidth,inCoeff);
  
  // call the computational routine
    calculate_ghat(bandwidth,inCoeff,makeEven,isReal,isAntipodal,sym_axis,outFourierCoeff,(mwSize)nrows);

  // free the storage
  mxDestroyArray(zeiger);

}