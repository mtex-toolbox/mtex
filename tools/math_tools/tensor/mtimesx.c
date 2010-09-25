/*************************************************************************************
 *
 * MATLAB (R) is a trademark of The Mathworks (R) Corporation
 *
 * Function:    mtimesx
 * Filename:    mtimesx.c
 * Programmer:  James Tursa
 * Version:     1.30
 * Date:        August 2, 2010
 * Copyright:   (c) 2009, 2010 by James Tursa, All Rights Reserved
 *
 *  This code uses the BSD License:
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in
 *       the documentation and/or other materials provided with the distribution
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *
 * Requires: mtimesx_RealTimesReal.c
 *
 * mtimesx is a multiply function that utilizes BLAS calls and custom code for
 * matrix-matrix, matrix-vector, vector-vector, scalar-vector, scalar-matrix,
 * and scalar-array calculations. Full support is given for transpose, conjugate
 * transpose, and conjugate operations. Operands can be single, double, or
 * sparse double.  Sparse double matrices have direct support for scalar-matrix
 * operations ... all other computations involving sparse matrices are done
 * with calls to the MATLAB intrinsic functions.
 *
 * Building:
 *
 * mtimesx is typically self building. That is, the first time you call mtimesx,
 * the mtimesx.m file recognizes that the mex routine needs to be compiled and
 * then the compilation and linkage to the BLAS library will happen automatically.
 * If the automatic compilation does not work, then you can do it manually as
 * follows:
 * - Put all of the files in one directory that is on the MATLAB path (but don't
 *   put them in a toolbox directory)
 * - Make that directory the current directory.
 * - Create a string variable with the pathname and filename of the BLAS library
 *   file to use. e.g. for microsoft it may be something like the following:
 *
 * - Issue the following command at the MATLAB prompt.
 *   >> mex('mtimesx.c',lib_blas)
 *
 *   If you are on an older version of MATLAB then you may need to do this:
 *   >> mex('-DEFINEMWSIZE','-DEFINEMWSIGNEDINDEX','mtimesx.c',lib_blas)
 *
 *   And if you are on a linux machine then you may need to add the string
 *   '-DEFINEUNIX' to the mex command argument list.
 *
 * The usage is as follows (arguments in brackets [ ] are optional):
 *
 * Syntax
 *
 * M = mtimesx( [mode] )
 * C = mtimesx(A [,transa] ,B [,transb] [,mode])
 *
 * Description
 *
 * mtimesx performs the matrix calculation C = op(A) * op(B), where:
 *    A = A single or double or sparse scalar, matrix, or array.
 *    B = A single or double or sparse scalar, matrix, or array.
 *    transa = A character indicating a pre-operation on A (optional)
 *    transb = A character indicating a pre-operation on B (optional)
 *             The pre-operation can be any of:
 *             'N' or 'n' = No operation (the default if trans_ is missing)
 *             'T' or 't' = Transpose
 *             'C' or 'c' = Conjugate Transpose
 *             'G' or 'g' = Conjugate (no transpose)
 *    mode = 'MATLAB' or 'SPEED' (sets mode for current and future calculations,
 *                                case insensitive, optional)
 *    M is a string indicating the current calculation mode, before setting the new one.
 *    C is the result of the matrix multiply operation.
 *
 *  mtimesx uses a combination of BLAS library routine calls and custom code
 *  to optimize the matrix or scalar multiplies with respect to speed
 *  without sacrificing accuracy. As a result, some calculations are done in
 *  a different way than the equivalent MATLAB calculation, resulting in
 *  slightly different answers. Although slightly different, the mtimesx
 *  results are just as accurate as the MATLAB results. The general matrix
 *  multiply calculation uses the same BLAS calls as MATLAB, so there is no
 *  difference in speed or results for this case. For the scalar * matrix,
 *  scalar * vector, scalar * array, and matrix * vector cases there
 *  generally *will* be a difference between mtimesx and the MATLAB built in
 *  mtimes function. Usually, mtimesx will be faster that the equivalent
 *  MATLAB function, but some of these cases are slightly slower.
 *
 *  M = mtimesx returns a string with the current calculation mode. The string
 *      will either be 'MATLAB' or 'SPEED'.
 *
 *  M = mtimesx(mode) sets the calculation mode to mode. The mode variable
 *      must be either the string 'MATLAB' or the string 'SPEED'. The return
 *      variable M is the previous mode setting prior to setting the new mode.
 *      The mode is case insensitive (lower or upper case is OK).
 *
 * Mode:
 *
 * The 'MATLAB' mode uses the same sequence of BLAS calls that MATLAB does,
 * and uses scalar multiply code that generates the same results as MATLAB.
 * The purpose of this mode is to reproduce the exact same results as the
 * same MATLAB operation. As such, there will often be no speed improvement
 * by using mtimesx vs using the MATLAB intrinsic mtimes.
 *
 * The 'SPEED' mode uses different sequences of BLAS calls than MATLAB does
 * whenever a speed improvement might be realized. Custom code for dot product
 * calculations is used, and certain matrix-matrix and matrix-vector operations
 * involving conjugates and/or transposes uses a series of dot product type
 * calculations instead of calling BLAS routines if a speed improvement can
 * be realized. This mode produces results that will sometimes differ slightly
 * from the same MATLAB operation, but the results will still be accurate.
 *
 * Examples:
 *
 *  C = mtimesx(A,B)         % performs the calculation C = A * B
 *  C = mtimesx(A,'T',B)     % performs the calculation C = A.' * B
 *  C = mtimesx(A,B,'G')     % performs the calculation C = A * conj(B)
 *  C = mtimesx(A,'C',B,'C') % performs the calculation C = A' * B'
 *  mtimesx                  % returns the current calculation mode
 *  mtimesx('MATLAB')        % sets calculation mode to match MATLAB
 *
 * Note: You cannot combine double sparse and single inputs, since MATLAB does not
 * support a single sparse result. You also cannot combine sparse inputs with full
 * nD (n > 2) inputs, since MATLAB does not support a sparse nD result. The only
 * exception is a sparse scalar times an nD full array. In that special case,
 * mtimesx will treat the sparse scalar as a full scalar and return a full nD result.
 *
 * Note: The �N�, �T�, and �C� have the same meanings as the direct inputs to the BLAS
 * routines. The �G� input has no direct BLAS counterpart, but was relatively easy to
 * implement in mtimesx and saves time (as opposed to computing conj(A) or conj(B)
 * explicitly before calling mtimesx).
 *
 * mtimesx supports nD inputs. For these cases, the first two dimensions specify the
 * matrix multiply involved. The remaining dimensions are duplicated and specify the
 * number of individual matrix multiplies to perform for the result. i.e., mtimesx
 * treats these cases as arrays of 2D matrices and performs the operation on the
 * associated parings. For example:
 *
 *     If A is (2,3,4,5) and B is (3,6,4,5), then
 *     mtimesx(A,B) would result in C(2,6,4,5)
 *     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,i,j), i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(2,6,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = A(:,:,m,n) * B(:,:,m,n);
 *         end
 *     end
 *
 * The first two dimensions must conform using the standard matrix multiply rules
 * taking the transa and transb pre-operations into account, and dimensions 3:end
 * must match exactly or be singleton (equal to 1). If a dimension is singleton
 * then it is virtually expanded to the required size (i.e., equivalent to a
 * repmat operation to get it to a conforming size but without the actual data
 * copy). For example:
 *
 *     If A is (2,3,4,5) and B is (3,6,1,5), then
 *     mtimesx(A,B) would result in C(2,6,4,5)
 *     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,1,j), i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(2,6,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = A(:,:,m,n) * B(:,:,1,n);
 *         end
 *     end
 *
 * When a transpose (or conjugate transpose) is involved, the first two dimensions
 * are transposed in the multiply as you would expect. For example:
 *
 *     If A is (3,2,4,5) and B is (3,6,4,5), then
 *     mtimesx(A,'C',B,'G') would result in C(2,6,4,5)
 *     where C(:,:,i,j) = A(:,:,i,j)' * conj( B(:,:,i,j) ), i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(2,6,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = A(:,:,m,n)' * conj( B(:,:,m,n) );
 *         end
 *     end
 *
 *     If A is a scalar (1,1) and B is (3,6,4,5), then
 *     mtimesx(A,'G',B,'C') would result in C(6,3,4,5)
 *     where C(:,:,i,j) = conj(A) * B(:,:,i,j)', i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(6,3,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = conj(A) * B(:,:,m,n)';
 *         end
 *     end
 *
 * Change Log:
 * 2009/Sep/27 --> 1.00, Initial Release
 * 2009/Dec/10 --> 1.11, Fixed bug for empty transa & transb inputs
 * 2010/Feb/23 --> 1.20, Fixed bug for dgemv and sgemv calls
 * 2010/Aug/02 --> 1.30, Added (nD scalar) * (nD array) capability
 *                       Replaced buggy mxRealloc with custom routine
 *
 ****************************************************************************/

/* Includes ----------------------------------------------------------- */

#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <math.h>
#include "mex.h"

/* Macros ------------------------------------------------------------- */

#ifdef DEFINEMWSIZE
#define  mwSize    int
#define  mwSize_t  size_t
#define  mwIndex   int
#else
#define  mwSize_t  mwSize
#endif

#ifdef DEFINEMWSIGNEDINDEX
#define  mwSignedIndex  int
#endif

/* Prototypes --------------------------------------------------------- */

mxArray *DoubleTimesDouble(mxArray *, char, mxArray *, char);
mxArray *FloatTimesFloat(mxArray *, char, mxArray *, char);
mxArray *mxCreateSharedDataCopy(const mxArray *pr);
char mxArrayToTrans(mxArray *mx);
void *myRealloc(void *vp, mwSize_t n);
void mtimesx_logo(void);

/* Global Variables --------------------------------------------------- */

int matlab = 1;

/*--------------------------------------------------------------------- */

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    mxArray *A, *B, *C, *Araw, *Braw;
    mxArray *rhs[4];
    char transa, transb;
    char *directive, *cp;
    char transstring[2] = "_";
    int unsupported = 0;
    int k;

/*-------------------------------------------------------------------------
 * Check for proper number of inputs and outputs
 *------------------------------------------------------------------------- */

    if( nrhs > 5 ) {
        mexErrMsgTxt("Must have 0 - 5 inputs.");
    }
    if( nlhs > 1 ) {
        mexErrMsgTxt("Must have at most 1 output.");
    }

/*-------------------------------------------------------------------------
 * If no inputs, just return the current mode
 *------------------------------------------------------------------------- */

    if( nrhs == 0 ) {
        if( matlab ) {
            plhs[0] = mxCreateString("MATLAB");
        } else {
            plhs[0] = mxCreateString("SPEED");
        }
        return;
    }

/*-------------------------------------------------------------------------
 * Find out if last input is a directive
 *------------------------------------------------------------------------- */

    if( mxIsChar(prhs[nrhs-1]) ) {
        if( cp = directive = mxArrayToString(prhs[nrhs-1]) ) {
            k = matlab;
            while( *cp ) {
                *cp = toupper( *cp );
                cp++;
            }
            if( strcmp(directive,"MATLAB") == 0 ) {
                matlab = 1;
                nrhs--;
            } else if( strcmp(directive,"SPEED") == 0 ) {
                matlab = 0;
                nrhs--;
            } else if( strcmp(directive,"LOGO") == 0 ) {
                mtimesx_logo();
                nrhs--;
            }
            mxFree(directive);
        } else {
            mexErrMsgTxt("Error allocating memory for directive string");
        }
        if( nrhs == 0 ) {
            if( k ) {
                plhs[0] = mxCreateString("MATLAB");
            } else {
                plhs[0] = mxCreateString("SPEED");
            }
            return;
        }
    }

    if( nrhs < 2 || nrhs > 4 ) {
        mexErrMsgTxt("Must have 2 - 4 inputs for multiply function");
    }

/*-------------------------------------------------------------------------
 * Pick off the transpose character inputs. If they are missing or empty
 * or blank, then use 'N' by default.
 *------------------------------------------------------------------------- */

    Araw = (mxArray *) prhs[0];
    if( nrhs == 2 ) {
        transa = 'N';
        Braw = (mxArray *) prhs[1];
        transb = 'N';
    } else if( nrhs == 3 ) {
        if( mxIsChar(prhs[1]) ) {
            transa = mxArrayToTrans(prhs[1]);
            Braw = (mxArray *) prhs[2];
            transb = 'N';
        } else if( mxIsChar(prhs[2]) ) {
            transa = 'N';
            Braw = (mxArray *) prhs[1];
            transb = mxArrayToTrans(prhs[2]);
        } else {
            mexErrMsgTxt("2nd or 3rd input must be char.");
        }
    } else { /* nrhs == 4 */
        if( mxIsChar(prhs[1]) && mxIsChar(prhs[3]) ) {
            transa = mxArrayToTrans(prhs[1]);
            Braw = (mxArray *) prhs[2];
            transb = mxArrayToTrans(prhs[3]);
        } else {
            mexErrMsgTxt("2nd and 4th inputs must be char.");
        }
    }

/*-----------------------------------------------------------------------------
 * Check for valid TRANS characters
 *----------------------------------------------------------------------------- */

    if( transa == 'n' ) transa = 'N';
    if( transa == 't' ) transa = 'T';
    if( transa == 'c' ) transa = 'C';
    if( transa == 'g' ) transa = 'G';
    if( transb == 'n' ) transb = 'N';
    if( transb == 't' ) transb = 'T';
    if( transb == 'c' ) transb = 'C';
    if( transb == 'g' ) transb = 'G';
    if( (transa != 'N' && transa != 'T' && transa != 'C' && transa != 'G') ||
        (transb != 'N' && transb != 'T' && transb != 'C' && transb != 'G') ) {
        mexErrMsgTxt("Invalid TRANS character. Expected N, T, C, or G.");
    }

/*-----------------------------------------------------------------------------
 * Check for proper input type and call the appropriate multiply routine.
 * To be similar to MATLAB for mixed single-double operations, convert
 * single inputs to double, do the calc, then convert back to single.
 *----------------------------------------------------------------------------- */

/* Future Enhancement: Put in special code for scalar multiplies, do calc in double */

    if( mxIsDouble(Araw) ) {
        if( mxIsDouble(Braw) ) {
            if( mxIsSparse(Araw) && !mxIsSparse(Braw)  &&
                (mxGetNumberOfElements(Araw) != 1 || mxGetNumberOfDimensions(Braw) == 2) ) {
                k = mexCallMATLAB(1, &B, 1, &Braw, "sparse");
                plhs[0] = DoubleTimesDouble(Araw, transa, B, transb);
                mxDestroyArray(B);
            } else if( !mxIsSparse(Araw) && mxIsSparse(Braw) &&
                (mxGetNumberOfElements(Braw) != 1 || mxGetNumberOfDimensions(Araw) == 2) ) {
                k = mexCallMATLAB(1, &A, 1, &Araw, "sparse");
                plhs[0] = DoubleTimesDouble(A, transa, Braw, transb);
                mxDestroyArray(A);
            } else {
                plhs[0] = DoubleTimesDouble(Araw, transa, Braw, transb);
            }
        } else if( mxIsSingle(Braw) ) {
            if( mxIsSparse(Araw) ) {
                mexErrMsgTxt("Sparse single arrays are not supported.");
            } else if( mxGetNumberOfElements(Araw) == 1 || mxGetNumberOfElements(Braw) == 1 ) {
                k = mexCallMATLAB(1, &B, 1, &Braw, "double");
                C = DoubleTimesDouble(Araw, transa, B, transb);
                mxDestroyArray(B);
                k = mexCallMATLAB(1, plhs, 1, &C, "single");
                mxDestroyArray(C);
            } else {
                k = mexCallMATLAB(1, &A, 1, &Araw, "single");
                plhs[0] = FloatTimesFloat(A, transa, Braw, transb);
                mxDestroyArray(A);
            }
        } else {
            unsupported = 1;
        }
    } else if( mxIsSingle(Araw) ) {
        if( mxIsDouble(Braw) ) {
            if( mxIsSparse(Braw) ) {
                mexErrMsgTxt("Sparse single arrays are not supported.");
            } else if( mxGetNumberOfElements(Araw) == 1 || mxGetNumberOfElements(Braw) == 1 ) {
                k = mexCallMATLAB(1, &A, 1, &Araw, "double");
                C = DoubleTimesDouble(A, transa, Braw, transb);
                mxDestroyArray(A);
                k = mexCallMATLAB(1, plhs, 1, &C, "single");
                mxDestroyArray(C);
            } else {
                k = mexCallMATLAB(1, &B, 1, &Braw, "single");
                plhs[0] = FloatTimesFloat(Araw, transa, B, transb);
                mxDestroyArray(B);
            }
        } else if( mxIsSingle(Braw) ) {
            plhs[0] = FloatTimesFloat(Araw, transa, Braw, transb);
        } else {
            unsupported = 1;
        }
    } else {
        unsupported = 1;
    }
    if( unsupported ) {
        rhs[0] = Araw;
        transstring[0] = transa;
        rhs[1] = mxCreateString(transstring);
        rhs[2] = Braw;
        transstring[0] = transb;
        rhs[3] = mxCreateString(transstring);
        k = mexCallMATLAB(1, plhs, 4, rhs, "mtimesx_sparse");
        mxDestroyArray(rhs[3]);
        mxDestroyArray(rhs[1]);
    }

    return;

}

/*-------------------------------------------------------------------------------
 *
 * Convert mxArray char input into trans character.
 *
 *------------------------------------------------------------------------------- */

char mxArrayToTrans(mxArray *mx)
{
    mwSize n;
    char *cp;
    char trans;

    if( cp = mxArrayToString(mx) ) {
        n = mxGetNumberOfElements(mx);
        if( n == 0 ) {
            trans = 'N';  /* Treat empty char strings the same as 'N' */
        } else {
            trans = *cp;  /* Pick off only the first character */
        }
        mxFree(cp);
    } else {
        mexErrMsgTxt("Error allocating memory for trans string");
    }
    return trans;
}

/*-------------------------------------------------------------------------------
 *
 * Clean a real sparse matrix of zeros. The code is a bit ugly because it was
 * highly optimized for speed.
 *
 *------------------------------------------------------------------------------- */

mwIndex spcleanreal(mxArray *mx)
{
    mwSize n, nrow;
    mwIndex *ir, *jc, *iz;
    mwIndex j, x, y, diff;
    double *pr, *pz;

    n = mxGetN(mx);
    pz = pr = mxGetData(mx);
    ir = mxGetIr(mx);
    jc = mxGetJc(mx);

    diff = 0;
    for( y=0; y<n; y++ ) {
        nrow = jc[y+1] - jc[y];
        for( x=0; x<nrow; x++ ) {
            if( *pr == 0.0 ) {
                iz = (ir += (pr - pz));
                pz = pr;
                j = y + 1;
                goto copydata;
            }
            pr++;
        }
    }
    return jc[n];

    for( y=0; y<n; y++ ) {
        j = y + 1;
        nrow = (jc[j] - diff) - jc[y];
        for( x=0; x<nrow; x++ ) {
            if( *pr != 0.0 ) {
                *pz++ = *pr;
                *iz++ = *ir;
            } else {
                copydata:
                diff++;
            }
            pr++;
            ir++;
        }
        jc[j] -= diff;
    }
    return jc[n];
}


/*-------------------------------------------------------------------------------
 *
 * Clean a complex sparse matrix of zeros. The code is a bit ugly because it was
 * highly optimized for speed.
 *
 *------------------------------------------------------------------------------- */

mwIndex spcleancomplex(mxArray *mx)
{
    mwSize n, nrow;
    mwIndex *ir, *jc, *iz;
    mwIndex j, x, y, diff;
    double *pr, *pz;
    double *pi, *py;

    n = mxGetN(mx);
    pz = pr = mxGetData(mx);
    py = pi = mxGetImagData(mx);
    ir = mxGetIr(mx);
    jc = mxGetJc(mx);

    diff = 0;
    for( y=0; y<n; y++ ) {
        nrow = jc[y+1] - jc[y];
        for( x=0; x<nrow; x++ ) {
            if( *pr == 0.0 && *pi == 0.0 ) {
                iz = (ir += (pr - pz));
                pz = pr;
                py = pi;
                j = y + 1;
                goto copydata;
            }
            pr++;
            pi++;
        }
    }
    return jc[n];

    for( y=0; y<n; y++ ) {
        j = y + 1;
        nrow = (jc[j] - diff) - jc[y];
        for( x=0; x<nrow; x++ ) {
            if( *pr != 0.0 || *pi != 0.0 ) {
                *pz++ = *pr;
                *py++ = *pi;
                *iz++ = *ir;
            } else {
                copydata:
                diff++;
            }
            pr++;
            pi++;
            ir++;
        }
        jc[j] -= diff;
    }
    return jc[n];
}

/*------------------------------------------------------------------------------- */

mwIndex spclean(mxArray *mx)
{
    if( mxIsComplex(mx) ) {
        return spcleancomplex(mx);
    } else {
        return spcleanreal(mx);
    }
}

/*-------------------------------------------------------------------------------
 * myRealloc for use only in cases of decreasing a block size. Avoids using the
 * buggy mxRealloc function for this case.
 *------------------------------------------------------------------------------- */

void *myRealloc(void *vp, mwSize_t n)
{
    void *xp;

    if( xp = mxMalloc(n) ) { /* not really a necessary test for a mex routine */
        memcpy(xp, vp, n);
        mxFree(vp);
        return xp;
    } else {
        return vp;
    }
}

/*-------------------------------------------------------------------------------
 * Logo.
 *------------------------------------------------------------------------------- */


void mtimesx_logo(void)
{
    mxArray *rhs[9];
    double *x, *y, *z;
    double r;
    mwSize i, j;
    
    mexCallMATLAB(1, rhs, 0, NULL, "figure");
    
    rhs[1] = mxCreateString("Color");
    rhs[2] = mxCreateDoubleMatrix(1, 3, mxREAL);
    x = mxGetPr(rhs[2]);
    x[0] = x[1] = x[2] = 1.0;
    mexCallMATLAB(0, NULL, 3, rhs, "set");
    mxDestroyArray(rhs[0]);
    mxDestroyArray(rhs[1]);
    mxDestroyArray(rhs[2]);
    
    rhs[0] = mxCreateDoubleMatrix(257, 257, mxREAL);
    rhs[1] = mxCreateDoubleMatrix(257, 257, mxREAL);
    rhs[2] = mxCreateDoubleMatrix(257, 257, mxREAL);
    x = mxGetPr(rhs[0]);
    y = mxGetPr(rhs[1]);
    z = mxGetPr(rhs[2]);
    for( i=0; i<257; i++ ) {
        for( j=0; j<257; j++ ) {
            *x = -8.0 + i * 0.0625;
            *y = -8.0 + j * 0.0625;
            r = sqrt((*x)*(*x) + (*y)*(*y)) + 2.22e-16;
            *z++ = sin(r) / r;
            x++;
            y++;
        }
    }

    rhs[3] = mxCreateString("FaceColor");
    rhs[4] = mxCreateString("interp");
    rhs[5] = mxCreateString("EdgeColor");
    rhs[6] = mxCreateString("none");
    rhs[7] = mxCreateString("FaceLighting");
    rhs[8] = mxCreateString("phong");
    mexCallMATLAB(0, NULL, 9, rhs, "surf");
    for( i=0; i<9; i++ ) {
        mxDestroyArray(rhs[i]);
    }
    
    rhs[0] = mxCreateDoubleMatrix(1, 3, mxREAL);
    x = mxGetPr(rhs[0]);
    x[0] = 5.0;
    x[1] = 5.0;
    x[2] = 1.0;
    mexCallMATLAB(0, NULL, 1, rhs, "daspect");
    mxDestroyArray(rhs[0]);
    
    rhs[0] = mxCreateString("tight");
    mexCallMATLAB(0, NULL, 1, rhs, "axis");
    mxDestroyArray(rhs[0]);
    
    rhs[0] = mxCreateString("off");
    mexCallMATLAB(0, NULL, 1, rhs, "axis");
    mxDestroyArray(rhs[0]);
    
    rhs[0] = mxCreateDoubleMatrix(1, 2, mxREAL);
    x = mxGetPr(rhs[0]);
    x[0] = -50.0;
    x[1] =  30.0;
    mexCallMATLAB(0, NULL, 1, rhs, "view");
    mxDestroyArray(rhs[0]);
    
    rhs[0] = mxCreateString("left");
    mexCallMATLAB(0, NULL, 1, rhs, "camlight");
    mxDestroyArray(rhs[0]);
}

/*-------------------------------------------------------------------------
 * Macros to define CAPITAL letters as the address of the lower case letter
 * This will make the function calls look much cleaner
 *------------------------------------------------------------------------- */

#define  M         &m
#define  K         &k
#define  L         &l
#define  N         &n
#define  M1        &m1
#define  N1        &n1
#define  M2        &m2
#define  N2        &n2
#define  LDA       &lda
#define  LDB       &ldb
#define  LDC       &ldc
#define  ZERO      &Zero
#define  ONE       &One
#define  MINUSONE  &Minusone
#define  TRANSA    &transa
#define  TRANSB    &transb
#define  TRANS     &trans
#define  PTRANSA   &ptransa
#define  PTRANSB   &ptransb
#define  INCX      &inc
#define  INCY      &inc
#define  ALPHA     &alpha
#define  UPLO      &uplo

/*-------------------------------------------------------------------------
 * Number of bytes that a sparse matrix result has to drop by before a
 * realloc will be performed on the data area(s).
 *------------------------------------------------------------------------- */

#define  REALLOCTOL  1024

/*-------------------------------------------------------------------------
 * Macros for the double * double function. All of the generic function
 * names and variable types in the file mtimesx_RealTimesReal.c are to be
 * replace with these names specific to the double type.
 *------------------------------------------------------------------------- */

#define  MatlabReturnType  mxDOUBLE_CLASS
#define  RealTimesReal  DoubleTimesDouble
#define  RealTimesScalar  DoubleTimesScalar
#define  AllRealZero  AllDoubleZero
#define  RealKindEqP1P0TimesRealKindN  DoubleImagEqP1P0TimesDoubleImagN
#define  RealKindEqP1P0TimesRealKindG  DoubleImagEqP1P0TimesDoubleImagG
#define  RealKindEqP1P0TimesRealKindT  DoubleImagEqP1P0TimesDoubleImagT
#define  RealKindEqP1P0TimesRealKindC  DoubleImagEqP1P0TimesDoubleImagC
#define  RealKindEqP1P1TimesRealKindN  DoubleImagEqP1P1TimesDoubleImagN
#define  RealKindEqP1P1TimesRealKindG  DoubleImagEqP1P1TimesDoubleImagG
#define  RealKindEqP1P1TimesRealKindT  DoubleImagEqP1P1TimesDoubleImagT
#define  RealKindEqP1P1TimesRealKindC  DoubleImagEqP1P1TimesDoubleImagC
#define  RealKindEqP1M1TimesRealKindN  DoubleImagEqP1M1TimesDoubleImagN
#define  RealKindEqP1M1TimesRealKindG  DoubleImagEqP1M1TimesDoubleImagG
#define  RealKindEqP1M1TimesRealKindT  DoubleImagEqP1M1TimesDoubleImagT
#define  RealKindEqP1M1TimesRealKindC  DoubleImagEqP1M1TimesDoubleImagC
#define  RealKindEqP1PxTimesRealKindN  DoubleImagEqP1PxTimesDoubleImagN
#define  RealKindEqP1PxTimesRealKindG  DoubleImagEqP1PxTimesDoubleImagG
#define  RealKindEqP1PxTimesRealKindT  DoubleImagEqP1PxTimesDoubleImagT
#define  RealKindEqP1PxTimesRealKindC  DoubleImagEqP1PxTimesDoubleImagC
#define  RealKindEqM1P1TimesRealKindN  DoubleImagEqM1P1TimesDoubleImagN
#define  RealKindEqM1P1TimesRealKindG  DoubleImagEqM1P1TimesDoubleImagG
#define  RealKindEqM1P1TimesRealKindT  DoubleImagEqM1P1TimesDoubleImagT
#define  RealKindEqM1P1TimesRealKindC  DoubleImagEqM1P1TimesDoubleImagC
#define  RealKindEqM1M1TimesRealKindN  DoubleImagEqM1M1TimesDoubleImagN
#define  RealKindEqM1M1TimesRealKindG  DoubleImagEqM1M1TimesDoubleImagG
#define  RealKindEqM1M1TimesRealKindT  DoubleImagEqM1M1TimesDoubleImagT
#define  RealKindEqM1M1TimesRealKindC  DoubleImagEqM1M1TimesDoubleImagC
#define  RealKindEqM1PxTimesRealKindN  DoubleImagEqM1PxTimesDoubleImagN
#define  RealKindEqM1PxTimesRealKindG  DoubleImagEqM1PxTimesDoubleImagG
#define  RealKindEqM1PxTimesRealKindT  DoubleImagEqM1PxTimesDoubleImagT
#define  RealKindEqM1PxTimesRealKindC  DoubleImagEqM1PxTimesDoubleImagC
#define  RealKindEqM1P0TimesRealKindN  DoubleImagEqM1P0TimesDoubleImagN
#define  RealKindEqM1P0TimesRealKindG  DoubleImagEqM1P0TimesDoubleImagG
#define  RealKindEqM1P0TimesRealKindT  DoubleImagEqM1P0TimesDoubleImagT
#define  RealKindEqM1P0TimesRealKindC  DoubleImagEqM1P0TimesDoubleImagC
#define  RealKindEqPxP1TimesRealKindN  DoubleImagEqPxP1TimesDoubleImagN
#define  RealKindEqPxP1TimesRealKindG  DoubleImagEqPxP1TimesDoubleImagG
#define  RealKindEqPxP1TimesRealKindT  DoubleImagEqPxP1TimesDoubleImagT
#define  RealKindEqPxP1TimesRealKindC  DoubleImagEqPxP1TimesDoubleImagC
#define  RealKindEqPxM1TimesRealKindN  DoubleImagEqPxM1TimesDoubleImagN
#define  RealKindEqPxM1TimesRealKindG  DoubleImagEqPxM1TimesDoubleImagG
#define  RealKindEqPxM1TimesRealKindT  DoubleImagEqPxM1TimesDoubleImagT
#define  RealKindEqPxM1TimesRealKindC  DoubleImagEqPxM1TimesDoubleImagC
#define  RealKindEqPxP0TimesRealKindN  DoubleImagEqPxP0TimesDoubleImagN
#define  RealKindEqPxP0TimesRealKindG  DoubleImagEqPxP0TimesDoubleImagG
#define  RealKindEqPxP0TimesRealKindT  DoubleImagEqPxP0TimesDoubleImagT
#define  RealKindEqPxP0TimesRealKindC  DoubleImagEqPxP0TimesDoubleImagC
#define  RealKindEqPxPxTimesRealKindN  DoubleImagEqPxPxTimesDoubleImagN
#define  RealKindEqPxPxTimesRealKindG  DoubleImagEqPxPxTimesDoubleImagG
#define  RealKindEqPxPxTimesRealKindT  DoubleImagEqPxPxTimesDoubleImagT
#define  RealKindEqPxPxTimesRealKindC  DoubleImagEqPxPxTimesDoubleImagC

#ifdef DEFINEUNIX
#define  xDOT      ddot_
#define  xGER      dger_
#define  xGEMV     dgemv_
#define  xGEMM     dgemm_
#define  xSYRK     dsyrk_
#define  xSYR2K    dsyr2k_
#else
#define  xDOT      ddot
#define  xGER      dger
#define  xGEMV     dgemv
#define  xGEMM     dgemm
#define  xSYRK     dsyrk
#define  xSYR2K    dsyr2k
#endif

#define  xFILLPOS  dfillpos
#define  xFILLNEG  dfillneg
#define  zero      0.0
#define  one       1.0
#define  minusone -1.0
#define  RealKind              double
#define  RealKindComplex       doublecomplex
#define  RealKindDotProduct    doublecomplexdotproduct
#define  RealKindOuterProduct  doublecomplexouterproduct
#define  RealScalarTimesReal   doublescalartimesdouble

#include  "mtimesx_RealTimesReal.c"

/*----------------------------------------------------------------------
 * Undefine all of the double specific macros
 *---------------------------------------------------------------------- */

#undef  MatlabReturnType
#undef  RealTimesReal
#undef  RealTimesScalar
#undef  AllRealZero
#undef  RealKindEqP1P0TimesRealKindN
#undef  RealKindEqP1P0TimesRealKindG
#undef  RealKindEqP1P0TimesRealKindT
#undef  RealKindEqP1P0TimesRealKindC
#undef  RealKindEqP1P1TimesRealKindN
#undef  RealKindEqP1P1TimesRealKindG
#undef  RealKindEqP1P1TimesRealKindT
#undef  RealKindEqP1P1TimesRealKindC
#undef  RealKindEqP1M1TimesRealKindN
#undef  RealKindEqP1M1TimesRealKindG
#undef  RealKindEqP1M1TimesRealKindT
#undef  RealKindEqP1M1TimesRealKindC
#undef  RealKindEqP1PxTimesRealKindN
#undef  RealKindEqP1PxTimesRealKindG
#undef  RealKindEqP1PxTimesRealKindT
#undef  RealKindEqP1PxTimesRealKindC
#undef  RealKindEqM1P1TimesRealKindN
#undef  RealKindEqM1P1TimesRealKindG
#undef  RealKindEqM1P1TimesRealKindT
#undef  RealKindEqM1P1TimesRealKindC
#undef  RealKindEqM1M1TimesRealKindN
#undef  RealKindEqM1M1TimesRealKindG
#undef  RealKindEqM1M1TimesRealKindT
#undef  RealKindEqM1M1TimesRealKindC
#undef  RealKindEqM1P0TimesRealKindN
#undef  RealKindEqM1P0TimesRealKindG
#undef  RealKindEqM1P0TimesRealKindT
#undef  RealKindEqM1P0TimesRealKindC
#undef  RealKindEqM1PxTimesRealKindN
#undef  RealKindEqM1PxTimesRealKindG
#undef  RealKindEqM1PxTimesRealKindT
#undef  RealKindEqM1PxTimesRealKindC
#undef  RealKindEqPxP1TimesRealKindN
#undef  RealKindEqPxP1TimesRealKindG
#undef  RealKindEqPxP1TimesRealKindT
#undef  RealKindEqPxP1TimesRealKindC
#undef  RealKindEqPxM1TimesRealKindN
#undef  RealKindEqPxM1TimesRealKindG
#undef  RealKindEqPxM1TimesRealKindT
#undef  RealKindEqPxM1TimesRealKindC
#undef  RealKindEqPxP0TimesRealKindN
#undef  RealKindEqPxP0TimesRealKindG
#undef  RealKindEqPxP0TimesRealKindT
#undef  RealKindEqPxP0TimesRealKindC
#undef  RealKindEqPxPxTimesRealKindN
#undef  RealKindEqPxPxTimesRealKindG
#undef  RealKindEqPxPxTimesRealKindT
#undef  RealKindEqPxPxTimesRealKindC
#undef  xDOT
#undef  xGER
#undef  xGEMV
#undef  xGEMM
#undef  xSYRK
#undef  xSYR2K
#undef  xFILLPOS
#undef  xFILLNEG
#undef  zero
#undef  one
#undef  minusone
#undef  RealKind
#undef  RealKindComplex
#undef  RealKindDotProduct
#undef  RealKindOuterProduct
#undef  RealScalarTimesReal

/*-------------------------------------------------------------------------
 * Macros for the single * single function. All of the generic function
 * names and variable types in the file mtimesx_RealTimesReal.c are to be
 * replaced with these names specific to the single type.
 *------------------------------------------------------------------------- */

#define  MatlabReturnType  mxSINGLE_CLASS
#define  RealTimesReal  FloatTimesFloat
#define  RealTimesScalar  FloatTimesScalar
#define  AllRealZero  AllFloatZero
#define  RealKindEqP1P0TimesRealKindN  FloatImagEqP1P0TimesFloatImagN
#define  RealKindEqP1P0TimesRealKindG  FloatImagEqP1P0TimesFloatImagG
#define  RealKindEqP1P0TimesRealKindT  FloatImagEqP1P0TimesFloatImagT
#define  RealKindEqP1P0TimesRealKindC  FloatImagEqP1P0TimesFloatImagC
#define  RealKindEqP1P1TimesRealKindN  FloatImagEqP1P1TimesFloatImagN
#define  RealKindEqP1P1TimesRealKindG  FloatImagEqP1P1TimesFloatImagG
#define  RealKindEqP1P1TimesRealKindT  FloatImagEqP1P1TimesFloatImagT
#define  RealKindEqP1P1TimesRealKindC  FloatImagEqP1P1TimesFloatImagC
#define  RealKindEqP1M1TimesRealKindN  FloatImagEqP1M1TimesFloatImagN
#define  RealKindEqP1M1TimesRealKindG  FloatImagEqP1M1TimesFloatImagG
#define  RealKindEqP1M1TimesRealKindT  FloatImagEqP1M1TimesFloatImagT
#define  RealKindEqP1M1TimesRealKindC  FloatImagEqP1M1TimesFloatImagC
#define  RealKindEqP1PxTimesRealKindN  FloatImagEqP1PxTimesFloatImagN
#define  RealKindEqP1PxTimesRealKindG  FloatImagEqP1PxTimesFloatImagG
#define  RealKindEqP1PxTimesRealKindT  FloatImagEqP1PxTimesFloatImagT
#define  RealKindEqP1PxTimesRealKindC  FloatImagEqP1PxTimesFloatImagC
#define  RealKindEqM1P1TimesRealKindN  FloatImagEqM1P1TimesFloatImagN
#define  RealKindEqM1P1TimesRealKindG  FloatImagEqM1P1TimesFloatImagG
#define  RealKindEqM1P1TimesRealKindT  FloatImagEqM1P1TimesFloatImagT
#define  RealKindEqM1P1TimesRealKindC  FloatImagEqM1P1TimesFloatImagC
#define  RealKindEqM1M1TimesRealKindN  FloatImagEqM1M1TimesFloatImagN
#define  RealKindEqM1M1TimesRealKindG  FloatImagEqM1M1TimesFloatImagG
#define  RealKindEqM1M1TimesRealKindT  FloatImagEqM1M1TimesFloatImagT
#define  RealKindEqM1M1TimesRealKindC  FloatImagEqM1M1TimesFloatImagC
#define  RealKindEqM1P0TimesRealKindN  FloatImagEqM1P0TimesFloatImagN
#define  RealKindEqM1P0TimesRealKindG  FloatImagEqM1P0TimesFloatImagG
#define  RealKindEqM1P0TimesRealKindT  FloatImagEqM1P0TimesFloatImagT
#define  RealKindEqM1P0TimesRealKindC  FloatImagEqM1P0TimesFloatImagC
#define  RealKindEqM1PxTimesRealKindN  FloatImagEqM1PxTimesFloatImagN
#define  RealKindEqM1PxTimesRealKindG  FloatImagEqM1PxTimesFloatImagG
#define  RealKindEqM1PxTimesRealKindT  FloatImagEqM1PxTimesFloatImagT
#define  RealKindEqM1PxTimesRealKindC  FloatImagEqM1PxTimesFloatImagC
#define  RealKindEqPxP1TimesRealKindN  FloatImagEqPxP1TimesFloatImagN
#define  RealKindEqPxP1TimesRealKindG  FloatImagEqPxP1TimesFloatImagG
#define  RealKindEqPxP1TimesRealKindT  FloatImagEqPxP1TimesFloatImagT
#define  RealKindEqPxP1TimesRealKindC  FloatImagEqPxP1TimesFloatImagC
#define  RealKindEqPxM1TimesRealKindN  FloatImagEqPxM1TimesFloatImagN
#define  RealKindEqPxM1TimesRealKindG  FloatImagEqPxM1TimesFloatImagG
#define  RealKindEqPxM1TimesRealKindT  FloatImagEqPxM1TimesFloatImagT
#define  RealKindEqPxM1TimesRealKindC  FloatImagEqPxM1TimesFloatImagC
#define  RealKindEqPxP0TimesRealKindN  FloatImagEqPxP0TimesFloatImagN
#define  RealKindEqPxP0TimesRealKindG  FloatImagEqPxP0TimesFloatImagG
#define  RealKindEqPxP0TimesRealKindT  FloatImagEqPxP0TimesFloatImagT
#define  RealKindEqPxP0TimesRealKindC  FloatImagEqPxP0TimesFloatImagC
#define  RealKindEqPxPxTimesRealKindN  FloatImagEqPxPxTimesFloatImagN
#define  RealKindEqPxPxTimesRealKindG  FloatImagEqPxPxTimesFloatImagG
#define  RealKindEqPxPxTimesRealKindT  FloatImagEqPxPxTimesFloatImagT
#define  RealKindEqPxPxTimesRealKindC  FloatImagEqPxPxTimesFloatImagC

#ifdef DEFINEUNIX
#define  xDOT      sdot_
#define  xGER      sger_
#define  xGEMV     sgemv_
#define  xGEMM     sgemm_
#define  xSYRK     ssyrk_
#define  xSYR2K    ssyr2k_
#else
#define  xDOT      sdot
#define  xGER      sger
#define  xGEMV     sgemv
#define  xGEMM     sgemm
#define  xSYRK     ssyrk
#define  xSYR2K    ssyr2k
#endif

#define  xFILLPOS  sfillpos
#define  xFILLNEG  sfillneg
#define  zero       0.0f
#define  one        1.0f
#define  minusone  -1.0f
#define  RealKind              float
#define  RealKindComplex       floatcomplex
#define  RealKindDotProduct    floatcomplexdotproduct
#define  RealKindOuterProduct  floatcomplexouterproduct
#define  RealScalarTimesReal   floatscalartimesfloat

#include  "mtimesx_RealTimesReal.c"
