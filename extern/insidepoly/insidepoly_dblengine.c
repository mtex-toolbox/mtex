/*************************************************************************
 * MATLAB MEX ROUTINE insidepoly_dblengine.c
 *  [in on] = insidepoly_dblengine(x, y, Px1, Py1, Px2, Py2, tol) OR
 *
 *  [in on] = insidepoly_dblengine(x, y, Px1, Py1, Px2, Py2, tol, 
 *                                 first, last)
 *
 * PURPOSE: engine for check points inside a 2D polygon
 * Engine for double inputs
 *
 *  INPUTS:
 *  x, y: (n x 1) arrays
 *  Px1, Py1, Px2, Py2: (m x 1) arrays
 *  tol: scalar, distance to detect on-boundary points
 *  first, last: optional, presorting indexes, used when x is sorted and
 *      min(Px1,Px2) <= x(first:last) <= max(Px1,Px2) for all edges
 *
 *  OUTPUTS:
 *  in, on: (n x 1) logical arrays, true for points inside/on the boundary
 *  of the polygon
 *
 * Compilation:
 *  >> mex -O -v insidepoly_dblengine.c 
 *  (add -largeArrayDims mex option on 64-bit computer)
 * Author: Bruno Luong <brunoluong@yahoo.com>
 * History
 *  Original: 06-Jun-2010
 ************************************************************************/

#include "mex.h"
#include "matrix.h"
#include <math.h>

/* Uncomment this on older Matlab version where size_t has not been
 * defined */
/*
 * #define mwSize int
 * #define size_t int
 */

/* Define correct type depending on platform 
  You might have to modify here depending on your compiler */
#if defined(_MSC_VER) || defined(__BORLANDC__)
typedef unsigned __int8 uint08;
typedef __int8 int08;
#else /* LINUX + LCC, CAUTION: not tested by the author */
typedef unsigned char uint08;
typedef char int08;
#endif

/* Define the name for Inp1ut/Output ARGUMENTS */
#define X prhs[0]
#define Y prhs[1]
#define PX1 prhs[2]
#define PY1 prhs[3]
#define PX2 prhs[4]
#define PY2 prhs[5]
#define TOL prhs[6]
#define FIRST prhs[7]
#define LAST prhs[8]

#define IN plhs[0]
#define ON plhs[1]

/* Working type */
#define TYPE double
/* Gateway of insidepoly_dblengine */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
                     
    TYPE *x, *y;
    TYPE dPx, dPy;
    TYPE *xx, *yy, *xlast;
    TYPE *Px1, *Py1, *Px2, *Py2;
    TYPE x1, y1, x2, y2;
    TYPE a, b, c, tol, onthreshold;
    TYPE l2;
    TYPE cmin, cmax;
    TYPE xmin, xmax, ymin, ymax;
    int08 *in, *on, *ii, *oo;
    mwSize n, nvertices, npnt;
    double *dfirst, *dlast;
    mwSignedIndex first, last;
    int presorting;
    
    nvertices = mxGetM(PX1);
    npnt = mxGetM(X);  
            
    x = (TYPE*)mxGetData(X);
    y = (TYPE*)mxGetData(Y);
    Px1 = (TYPE*)mxGetData(PX1);
    Py1 = (TYPE*)mxGetData(PY1);
    Px2 = (TYPE*)mxGetData(PX2);
    Py2 = (TYPE*)mxGetData(PY2);
    
    IN = mxCreateLogicalMatrix(npnt, 1);
    /* in and on is already prefilled with 0 */
    in = (int08*)mxGetData(IN);
    
    ON = mxCreateLogicalMatrix(npnt, 1);
    on = (int08*)mxGetData(ON);
    
    tol = *(TYPE*)mxGetData(TOL);
    
    /* FIRST and LAST are provided */
    presorting = nrhs>=9;
    if (presorting)
    {
        dfirst = mxGetPr(FIRST);
        dlast = mxGetPr(LAST);
    }
            
    /* Loop on segments */
    for (n=0; n<nvertices; n++) {
        
        x1 = *Px1++;
        y1 = *Py1++;
        x2 = *Px2++;
        y2 = *Py2++;
        
        if (presorting) {
            /* Remove one to convert Matlab to C zero-based indexing */
            first = (mwSignedIndex)(dfirst[n])-1;
            last = (mwSignedIndex)(dlast[n])-1;
        }
        else {
            /* Scan all points */
            first = 0;
            last = npnt-1;
        }
        
        if (first>last) continue; /* Nothing to do */
        
        /* Some quantities depend only on the edge */
        dPx = x2-x1;
        dPy = y2-y1;
        a = x1*y2 - x2*y1;
        l2 = dPx*dPx + dPy*dPy;
        onthreshold = (TYPE)sqrt(l2)*tol;
        b = x1*dPy - y1*dPx;
        cmin = b-onthreshold;
        cmax = b+onthreshold;
        
        /* Initlialize pointers to the begining of the arrays before looping */
        xx = x+first;
        yy = y+first;
        ii = in+first;
        oo = on+first;
        /* The last pointer scanned by xx */
        xlast = x+last;
                
        /* Branching */
        if (dPx>0) { /* x2>x1 */
            /* Loop on data points */
            while (xx<=xlast) {
                if (*xx>=x1 && *xx<x2) {
                    c = *xx*dPy - *yy*dPx;
                    *ii ^= (c >= a);
                    *oo |= (c>cmin && c<cmax);
                }
                xx++;
                yy++;
                ii++;
                oo++;
            } /* while */
        } else if (dPx<0) { /* x2<x1 */
            /* Loop on data points */
            while (xx<=xlast) {
                if (*xx>=x2 && *xx<x1) {
                    c = *xx*dPy - *yy*dPx;
                    *ii ^= (c <= a);
                    *oo |= (c>cmin && c<cmax);
                }
                xx++;
                yy++;
                ii++;
                oo++;
            }  /* while */
        }
        else { /* (dPx == 0.0) x1==x2 */
            xmin = x1-tol;
            xmax = x1+tol;
            /* Process special cases for on-boundary test */
            if (dPy>0.0) /* y2 > y1 */ {
                ymin = y1;
                ymax = y2;
            }
            else { /* y2 <= y1 */
                ymin = y2;
                ymax = y1;
            }
                                
            /* Loop on data points */
            while (xx<=xlast) {
                *oo |= (*yy>=ymin && *yy<=ymax && *xx>xmin && *xx<xmax);
                xx++;
                yy++;
                oo++;
            }  /* while */
        } /* if dPx */

    } /* for-loop segments*/

    return;
}
