#include <string.h>
#include "mex.h"

#define MAX_NEIGHBOURS 8

struct IntStack {
    int* buffer;
    int index;
    int maxSize;
};
typedef struct IntStack IntStack;

// mex EulerCyclesC.c -R2018a

void calcEulerCycles(const mxArray *I_FG, const mxArray *F, const mxArray *V, mxArray **outGrains, mxArray **outCycles, mxArray **outCylcePoints);
void validateInputs(const mxArray *I_FG, const mxArray *F, const mxArray *V);
void calcEulerCyclesGrain(int grainIndex, mwIndex *FindexGrain, int nFGrain,int *VN, int *VNFindex, int *VNSize, double *F_doubles, int F_M, int *F_usable_global, IntStack* cyclePoints, IntStack* cycles);
static inline void push(IntStack *intStack, int value);


void mexFunction(int nOutputs, mxArray *outputs[], int nInputs, const mxArray *inputs[]) {
    if (nInputs != 3) {
        mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:nInputs","3 Inputs required!");
    }
    if (nOutputs != 3) {
        mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:nOutputs","3 Outputs required!");
    }

    calcEulerCycles(inputs[0], inputs[1], inputs[2], &outputs[0], &outputs[1], &outputs[2]);
}

void calcEulerCycles(const mxArray *I_FG, const mxArray *F, const mxArray *V, mxArray **outGrains, mxArray **outCycles, mxArray **outCyclePoints) {
    validateInputs(I_FG,F,V);

    int F_M = mxGetM(F);// number of faces
    double *F_doubles = mxGetDoubles(F);
    
    int V_M = mxGetM(V);// number of vertices

    int *VN = (int *) mxMalloc(sizeof(int)*V_M*MAX_NEIGHBOURS);// neighbour vertices
    int *VNFindex = (int *) mxMalloc(sizeof(int)*V_M*MAX_NEIGHBOURS);// neighbour faces
    int *VNSize = (int *) mxMalloc(sizeof(int)*V_M);// number of neighbours

    memset(VN, 0, sizeof(int)*V_M*MAX_NEIGHBOURS);
    memset(VNFindex, 0, sizeof(int)*V_M*MAX_NEIGHBOURS);
    memset(VNSize, 0, sizeof(int)*V_M);

    // for each face
    for (int i = 0; i < F_M; i++) {
        int vStart = (int)F_doubles[i] - 1;
        int vEnd = (int)F_doubles[i + F_M] - 1;
        // printf("%d %d %d %d %d %d\n",vStart,vEnd,vStart*MAX_NEIGHBOURS + VNSize[vStart],vEnd*MAX_NEIGHBOURS + VNSize[vEnd], VNSize[vStart], VNSize[vEnd]);

        if (vStart == vEnd) {
            mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:schlinge","Graph enthalt ne schlinge!");
        }

        if (vStart < 0 || vStart >= V_M || vEnd < 0 || vEnd >= V_M) {
            mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:VnotExist","Eine Kante enthalt Knoten, die es nicht gibt!");
        }

        if (VNSize[vStart] >= MAX_NEIGHBOURS || VNSize[vEnd] >= MAX_NEIGHBOURS) {
            mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:VN_max","Knoten hat zu viele Nachbarn!");
        }

        VN[vStart*MAX_NEIGHBOURS + VNSize[vStart]] = vEnd;// add neighbor
        VN[vEnd*MAX_NEIGHBOURS + VNSize[vEnd]] = vStart;// add neighbor
        VNFindex[vStart*MAX_NEIGHBOURS + VNSize[vStart]] = i;// set neighbour face
        VNFindex[vEnd*MAX_NEIGHBOURS + VNSize[vEnd]] = i;// set neighbour face

        VNSize[vStart] += 1;
        VNSize[vEnd] += 1;
    }

    int I_FG_N = mxGetN(I_FG);// number of columns I_FG
    mwIndex *I_FG_Ir = mxGetIr(I_FG);// Ir (sparse matrix)
    mwIndex *I_FG_Jc = mxGetJc(I_FG);// Jr (sparse matrix)
    double *I_FG_Pr = mxGetPr(I_FG);// Pr (sparse matrix)

    IntStack cyclePoints;
    cyclePoints.maxSize = V_M*4;// TODO erstmal annahme: jeder Punkt kommt in 4 Cyclen vor
    cyclePoints.buffer = mxMalloc(sizeof(int)*cyclePoints.maxSize);
    cyclePoints.index = 0;

    IntStack cycles;
    cycles.maxSize = I_FG_N*2*2;// TODO erstmal annahme: ein Korn hat durchschnittlich maximal 2 cyclen
    cycles.buffer = mxMalloc(sizeof(int)*cycles.maxSize);
    cycles.index = 0;

    // [grain1CyclesStartIndex, nCyclesGrain1, grain2CyclesStartIndex, nCyclesGrain2, ...]
    int* grainCycles = mxMalloc(sizeof(int)*I_FG_N*2);
    
    int *F_usable_global = mxMalloc(sizeof(int)*F_M);
    memset(F_usable_global, 0, sizeof(int)*F_M);

    // for each grain
    for (int I_FG_columnIndex = 0; I_FG_columnIndex < I_FG_N; I_FG_columnIndex++) {
        int I_FG_Pr_indexStart = I_FG_Jc[I_FG_columnIndex];
        int I_FG_Pr_indexEnd = I_FG_Jc[I_FG_columnIndex+1];
        int nFGrain = I_FG_Pr_indexEnd - I_FG_Pr_indexStart;// number of faces of this grain

        mwIndex* FindexGrain = &(I_FG_Ir[I_FG_Pr_indexStart]);// array of faces in this grain
        for (int j = 0; j < nFGrain; j++) {
            F_usable_global[I_FG_Ir[I_FG_Pr_indexStart + j]] = 1;
        }
        //printf("\n");

        grainCycles[I_FG_columnIndex*2] = cycles.index;// first cycle index of grain

        calcEulerCyclesGrain(I_FG_columnIndex, FindexGrain, nFGrain, VN, VNFindex, VNSize, F_doubles, F_M, F_usable_global, &cyclePoints, &cycles);
        
        grainCycles[I_FG_columnIndex*2 + 1] = cycles.index - grainCycles[I_FG_columnIndex*2];// number of added cycles

        // TODO: maybe not neccesary
        for (int j = 0; j < nFGrain; j++) {
            F_usable_global[I_FG_Ir[I_FG_Pr_indexStart + j]] = 0;
        }

    }

    // generate output data
    *outGrains = mxCreateDoubleMatrix(I_FG_N, 2, mxREAL);
    double* outGrains_doubles = mxGetDoubles(*outGrains);
    for (int i = 0; i < I_FG_N; i++) {
        outGrains_doubles[i] = grainCycles[i*2]/2 + 1;// cycles start Index (matlab)
        outGrains_doubles[i + I_FG_N] = grainCycles[i*2 + 1]/2;// number of cycles in this grain
    }

    *outCycles = mxCreateDoubleMatrix(cycles.index/2, 2, mxREAL);
    double* outCycles_doubles = mxGetDoubles(*outCycles);
    for (int i = 0; i < cycles.index/2; i++) {
        outCycles_doubles[i] = cycles.buffer[i*2] + 1;// points start Index (matlab)
        outCycles_doubles[i + cycles.index/2] = cycles.buffer[i*2 + 1];// number of Points
    }

    *outCyclePoints = mxCreateDoubleMatrix(cyclePoints.index, 1, mxREAL);
    double* outCyclePoints_doubles = mxGetDoubles(*outCyclePoints);
    for (int i = 0; i < cyclePoints.index; i++) {
        outCyclePoints_doubles[i] = cyclePoints.buffer[i] + 1;// points (index) (matlab)
    }


}

void calcEulerCyclesGrain(int grainIndex, mwIndex *FindexGrain, int nFGrain,int *VN, int *VNFindex, int *VNSize, double *F_doubles, int F_M, int *F_usable_global, IntStack* cyclePoints, IntStack* cycles) {
    // printf("calcEulerCyclesGrain(grainIndex=%d, nFGrain=%d)\n",grainIndex,nFGrain);
    // global: index in F_doubles; local: index in FindexGrain
    int startFLocal, startV, currentV;
    int nCyclePoints = 0;
    int currentFGlobal = -1;
    int nFUsed = 0;// number of used faces

    // while not all faces used
    while (nFUsed < nFGrain) {
        if (currentFGlobal == -1) {
            // find unused face:
            for (startFLocal = 0; startFLocal < nFGrain; startFLocal++) {
                currentFGlobal = FindexGrain[startFLocal];
                if (currentFGlobal < 0 || currentFGlobal >= F_M) {
                    printf("FEHLER: currentFGlobal=%d\n",currentFGlobal);
                    mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:currentFGlobal", "currentFGlobal < 0 || currentFGlobal >= F_M");
                }
                if (F_usable_global[currentFGlobal]) break;
            }
            //printf("startF=%d currentFGlobal=%d\n",startF,currentFGlobal);
    
            if (startFLocal >= nFGrain) mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:asdasdsad", "startF >= nFGrain");
            
            startV = (int)F_doubles[currentFGlobal] - 1;// one side of face
            currentV = (int)F_doubles[currentFGlobal + F_M] - 1;// the other side

            push(cycles, cyclePoints->index);// start new cycle. the first point is located at cyclePoints->index
            push(cyclePoints, currentV);// add first point
            nCyclePoints = 1;

            F_usable_global[currentFGlobal] = 0;// use face
            nFUsed++;
        } else {
            
            int next = -1;
            if (startV != currentV) {
                // if not at cycle start: find next face
                for (next = 0; next < VNSize[currentV]; next++) {
                    if (F_usable_global[VNFindex[currentV*MAX_NEIGHBOURS + next]]) break;
                }
            }
            //printf("next=%d\n",next);
            if (next == -1 || next == VNSize[currentV]) {
                // not found or at cycle start
                push(cycles, nCyclePoints);// finish cycle: set length
                nCyclePoints = 0;
                currentFGlobal = -1;
            } else {
                // found
                currentFGlobal = VNFindex[currentV*MAX_NEIGHBOURS + next];
                currentV = VN[currentV*MAX_NEIGHBOURS + next];

                push(cyclePoints, currentV);// add Point
                nCyclePoints += 1;// increase number of points

                F_usable_global[currentFGlobal] = 0;// use face
                nFUsed++;
            }
        }
    }
    if (nCyclePoints != 0) {
        push(cycles, nCyclePoints);// finish cycle: set length
    }
}

static inline void push(IntStack *intStack, int value) {
    //printf("push(%d) at index=%d maxSize=%d\n",value,index,maxSize);
    if (intStack->index >= intStack->maxSize) {
        mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:IntStackBufferFull", "buffer full!");
    }
    intStack->buffer[intStack->index] = value;
    intStack->index += 1;
}

void validateInputs(const mxArray *I_FG, const mxArray *F, const mxArray *V) {
    // check input
    if (!mxIsSparse(I_FG)) {
        mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:I_FG_notSparse","I_FG is not sparse");
    }

    if (mxGetM(I_FG) != mxGetM(F)) {
        mexErrMsgIdAndTxt("MTEX:CalcEulerCyclesC:I_FG_m","number of rows of I_FG does not match number of rows F");
    }
}

