// Fabian Bär

/** [grains, cycles, cyclePoints] = EulerCyclesC(I_FG,F,V)
 * calculates Euler cycles for each grain.
 *
 * grains: Each entry represents one grain, except for the last one. 
 *    For each grain, the first index of the cycles belonging to this grain is stored.
 *    The last element is the total number of cycles.
 *
 * cycles: Each entry represents one cycle, except for the last one.
 *   For each cycle, the first index of cyclePoints belonging to this cycle is stored.
 *   The last element is the total number of cyclePoints.
 *
 * cyclePoints: Array of point indices (V).
 */

// mex EulerCyclesC.c -R2018a

#include <string.h>
#include <stdarg.h>
#include "mex.h"

// maximum number of neighbors of a vertex
#define MAX_NEIGHBORS ( 8 )

#define ERROR_ID_PREFIX ( "MTEX:EulerCyclesC" )


// ------------ structs and types ------------

struct IntStack {
    int* buffer;
    int index;
    int maxSize;
};
typedef struct IntStack IntStack;

struct WorkingData {
    double *F_doubles;
    int F_M;// number of faces

    int V_M;// number of vertices

    int *VN;// VN[i*MAX_NEIGHBORS...] = [neigbor1ofPoint_i, neighbor2ofPoint_i, ...]
    int *VNFindex;// VNFindex[i*MAX_NEIGHBORS...] = [faceToNeighbor1ofPoint_i, faceToNeighbor2ofPoint_i, ...]
    int *VNSize;// VNSize[i] = number of neighbors of point i

    IntStack cyclePoints;
    IntStack cycles;
    int* grainCycles;
    int* F_usable_global;
    int* V_currentCycleIndex;

    IntStack currentCyclePoints;
};
typedef struct WorkingData WorkingData;


// ------------ function headers ------------

void calcEulerCycles(const mxArray *I_FG, const mxArray *F, const mxArray *V, mxArray **outGrains, mxArray **outCycles, mxArray **outCylcePoints);

void validateInputs(const mxArray *I_FG, const mxArray *F, const mxArray *V);

void buildNeighborList(WorkingData* w);

void calcEulerCyclesGrain(WorkingData* w, int grainIndex, mwIndex *FindexGrain, int nFGrain);

static inline void addNextPoint(WorkingData *w, int point);

static inline void push(IntStack *intStack, int value);

static inline void closeCycle(WorkingData *w, int startIndex);

static inline void finishCycles(WorkingData *w);

void initIntStack(IntStack *intStack, int maxSize);

void error(const char *id, const char *format, ...);



// ------------ function implementations ------------

void mexFunction(int nOutputs, mxArray *outputs[], int nInputs, const mxArray *inputs[]) {
    if (nInputs != 3) {
        error("nInputs","3 Inputs required! nInputs=%d",nInputs);
    }
    if (nOutputs != 3) {
        error("nOutputs","3 Outputs required! nOutputs=%d",nOutputs);
    }

    calcEulerCycles(inputs[0], inputs[1], inputs[2], &outputs[0], &outputs[1], &outputs[2]);
}


void calcEulerCycles(const mxArray *I_FG, const mxArray *F, const mxArray *V, mxArray **outGrains, mxArray **outCycles, mxArray **outCyclePoints) {
    validateInputs(I_FG,F,V);

    WorkingData w;


    // ------ read input data -----

    w.F_M = mxGetM(F);// number of faces
    w.F_doubles = mxGetDoubles(F);
    
    w.V_M = mxGetM(V);// number of vertices

    // read sparse I_FG_N matrix:
    int I_FG_N = mxGetN(I_FG);// number of columns I_FG
    mwIndex *I_FG_Ir = mxGetIr(I_FG);// Ir (sparse matrix)
    mwIndex *I_FG_Jc = mxGetJc(I_FG);// Jr (sparse matrix)
    double *I_FG_Pr = mxGetPr(I_FG);// Pr (sparse matrix)


    // ------ build data structures ------

    buildNeighborList(&w);

    // assumption: number of point occurrences < number of points * 4
    initIntStack(&(w.cyclePoints), w.V_M*4 + 1000);

    // asumption: number of cycles < number of grains * 2
    initIntStack(&(w.cycles), I_FG_N*2 + 1000);

    // [grain1CyclesStartIndex, grain2CyclesStartIndex, ..., numberOfCycles]
    w.grainCycles = mxMalloc(sizeof(int)*I_FG_N + 1);
    
    w.F_usable_global = mxMalloc(sizeof(int)*w.F_M);
    memset(w.F_usable_global, 0, sizeof(int)*w.F_M);

    w.V_currentCycleIndex = mxMalloc(sizeof(int)*w.V_M);
    memset(w.V_currentCycleIndex, -1, sizeof(int)*w.V_M);

    // asumption: max cycle size < 10000
    initIntStack(&(w.currentCyclePoints),10000);


    // ------ calculate cycles for each grain ------

    for (int grainIndex = 0; grainIndex < I_FG_N; grainIndex++) {
        // read sparse matrix
        int I_FG_Pr_indexStart = I_FG_Jc[grainIndex];
        int I_FG_Pr_indexEnd = I_FG_Jc[grainIndex+1];

        // array of faces in this grain
        mwIndex* FindexGrain = &(I_FG_Ir[I_FG_Pr_indexStart]);

        // number of faces in this grain
        int nFGrain = I_FG_Pr_indexEnd - I_FG_Pr_indexStart;

        // mark faces in this grain as usable
        for (int j = 0; j < nFGrain; j++) {
            w.F_usable_global[FindexGrain[j]] = 1;
        }

        // first cycle index of grain
        w.grainCycles[grainIndex] = w.cycles.index;

        // add all cycles of current grain
        calcEulerCyclesGrain(&w, grainIndex, FindexGrain, nFGrain);
        
        // maybe not neccesary: mark faces in this grain as not usable
        // (calcEulerCyclesGrain(...) should do that itself)
        for (int j = 0; j < nFGrain; j++) {
            w.F_usable_global[FindexGrain[j]] = 0;
        }

    }

    // finish grainCycles and cyclePoints
    w.grainCycles[I_FG_N] = w.cycles.index;// last element: total number of cycles
    push(&(w.cycles), w.cyclePoints.index);// last element: total number of cyclePoints
    

    // ------ generate output data ------

    *outGrains = mxCreateDoubleMatrix(I_FG_N + 1, 1, mxREAL);
    double* outGrains_doubles = mxGetDoubles(*outGrains);

    // for each grain (+last)
    for (int i = 0; i < I_FG_N+1; i++) {
        outGrains_doubles[i] = w.grainCycles[i] + 1;// cycles start Index (matlab: index starts with 1)
    }

    *outCycles = mxCreateDoubleMatrix(w.cycles.index, 1, mxREAL);
    double* outCycles_doubles = mxGetDoubles(*outCycles);
    for (int i = 0; i < w.cycles.index; i++) {
        outCycles_doubles[i] = w.cycles.buffer[i] + 1;// points start Index (matlab: index starts with 1)
    }

    *outCyclePoints = mxCreateDoubleMatrix(w.cyclePoints.index, 1, mxREAL);
    double* outCyclePoints_doubles = mxGetDoubles(*outCyclePoints);
    for (int i = 0; i < w.cyclePoints.index; i++) {
        outCyclePoints_doubles[i] = w.cyclePoints.buffer[i] + 1;// points (index) (matlab: index starts with 1)
    }
}


void buildNeighborList(WorkingData* w) {
    // allocate buffer
    w->VN = (int *) mxMalloc(sizeof(int)*w->V_M*MAX_NEIGHBORS);// neighbor vertices
    w->VNFindex = (int *) mxMalloc(sizeof(int)*w->V_M*MAX_NEIGHBORS);// neighbor faces
    w->VNSize = (int *) mxMalloc(sizeof(int)*w->V_M);// number of neighbors

    // fill with zeros
    memset(w->VN, 0, sizeof(int)*w->V_M*MAX_NEIGHBORS);
    memset(w->VNFindex, 0, sizeof(int)*w->V_M*MAX_NEIGHBORS);
    memset(w->VNSize, 0, sizeof(int)*w->V_M);
    
    // for each face
    for (int i = 0; i < w->F_M; i++) {
        int vStart = (int)w->F_doubles[i] - 1;
        int vEnd = (int)w->F_doubles[i + w->F_M] - 1;

        // validate face
        if (vStart < 0 || vStart >= w->V_M) {
            error("F_V_out_of_bounds", "face contains node index out of bounds: vStart=%d is not between 1,%d", vStart+1, w->F_M);
        }
        if (vEnd < 0 || vEnd >= w->V_M) {
            error("F_V_out_of_bounds", "face contains node index out of bounds: vEnd=%d is not between 1,%d", vEnd+1, w->F_M);
        }

        // prevent buffer overflow
        if (w->VNSize[vStart] >= MAX_NEIGHBORS || w->VNSize[vEnd] >= MAX_NEIGHBORS) {
            error("VN_max","A point has too many neighbors! MAX_NEIGHBORS=%d", MAX_NEIGHBORS);
        }

        w->VN[vStart*MAX_NEIGHBORS + w->VNSize[vStart]] = vEnd;// add neighbor
        w->VNFindex[vStart*MAX_NEIGHBORS + w->VNSize[vStart]] = i;// set corresponding neighbor face
        w->VNSize[vStart] += 1;

        if (vStart != vEnd) {
            // if no loop
            w->VN[vEnd*MAX_NEIGHBORS + w->VNSize[vEnd]] = vStart;// add neighbor
            w->VNFindex[vEnd*MAX_NEIGHBORS + w->VNSize[vEnd]] = i;// set corresponding neighbor face
            w->VNSize[vEnd] += 1;
        }
    }
}

void calcEulerCyclesGrain(WorkingData* w, int grainIndex, mwIndex *FindexGrain, int nFGrain) {
    // global: index in F_doubles; local: index in FindexGrain
    
    int startFLocal, startV, currentV;
    int currentFGlobal = -1;
    int nFUsed = 0;// number of used faces

    // while not all faces used
    while (nFUsed < nFGrain) {
        if (currentFGlobal == -1) {
            // find unused face:
            for (startFLocal = 0; startFLocal < nFGrain; startFLocal++) {
                currentFGlobal = FindexGrain[startFLocal];
                if (currentFGlobal < 0 || currentFGlobal >= w->F_M) {
                    error("internal:currentFGlobalOutOfBounds", "internal Error: currentFGlobal=%d out of bounds 0,%d",currentFGlobal,w->F_M - 1);
                }
                if (w->F_usable_global[currentFGlobal]) break;
            }
    
            if (startFLocal >= nFGrain) error("internal:startFLocal_nFGrain", "internal Error: startFLocal=%d >= nFGrain=%d", startFLocal, nFGrain);
            
            startV = (int)w->F_doubles[currentFGlobal] - 1;// one side of face
            currentV = (int)w->F_doubles[currentFGlobal + w->F_M] - 1;// the other side

            addNextPoint(w, startV);
            addNextPoint(w, currentV);


            w->F_usable_global[currentFGlobal] = 0;// use face
            nFUsed++;
        } else {
            
            int next;
            // find next face
            for (next = 0; next < w->VNSize[currentV]; next++) {
                if (w->F_usable_global[w->VNFindex[currentV*MAX_NEIGHBORS + next]]) break;
            }
            if (next == w->VNSize[currentV]) {
                // not found
                
                finishCycles(w);
                currentFGlobal = -1;
            } else {
                // found
                currentFGlobal = w->VNFindex[currentV*MAX_NEIGHBORS + next];
                currentV = w->VN[currentV*MAX_NEIGHBORS + next];
    
                addNextPoint(w, currentV);
    
                w->F_usable_global[currentFGlobal] = 0;// use face
                nFUsed++;
            }
        }
    }
    finishCycles(w);
}

static inline void addNextPoint(WorkingData *w, int point) {
    // printf("addNextPoint(w, %d)\n",point);
    if (w->V_currentCycleIndex[point] == -1) {
        // point not yet visited: cycle not closed

        // register point as visited
        w->V_currentCycleIndex[point] = w->currentCyclePoints.index;

        // add point to temporary list
        push(&(w->currentCyclePoints), point);
    } else {
        // point visited: cycle closed

        int startIndex = w->V_currentCycleIndex[point];
        closeCycle(w, startIndex);
    }
}

static inline void closeCycle(WorkingData *w, int startIndex) {
    //printf("closeCycle(w, %d)\n",startIndex);
    push(&(w->cycles), w->cyclePoints.index);// start new cycle. the first point is located at cyclePoints->index
    for (int i = startIndex; i < w->currentCyclePoints.index; i++) {
        
        int point = w->currentCyclePoints.buffer[i];
        push(&(w->cyclePoints), point);// add point

        if (i != startIndex) {
            // register point as unvisited
            w->V_currentCycleIndex[point] = -1;
        }
    }

    push(&(w->cyclePoints), w->currentCyclePoints.buffer[startIndex]);// add starting point again

    // remove everything after startIndex
    w->currentCyclePoints.index = startIndex + 1;
}

static inline void finishCycles(WorkingData *w) {
    //printf("finishCycles(w)\n");

    if (w->currentCyclePoints.index > 1) {
        // if cycle not closed:
        closeCycle(w,0);
    }

    if (w->currentCyclePoints.index == 1) {
        // register point as unvisited
        w->V_currentCycleIndex[w->currentCyclePoints.buffer[0]] = -1;
    }

    w->currentCyclePoints.index = 0;
}

static inline void push(IntStack *intStack, int value) {
    //printf("push(%d) at index=%d maxSize=%d\n",value,index,maxSize);
    if (intStack->index >= intStack->maxSize) {
        error("internal:IntStackBufferFull", "internal Error: IntStack buffer full! intStack->maxSize=%d",intStack->maxSize);
    }
    intStack->buffer[intStack->index] = value;
    intStack->index += 1;
}

void initIntStack(IntStack *intStack, int maxSize) {
    intStack->maxSize = maxSize;
    intStack->buffer = mxMalloc(sizeof(int)*maxSize);
    intStack->index = 0;
}

void validateInputs(const mxArray *I_FG, const mxArray *F, const mxArray *V) {
    // check input
    if (!mxIsSparse(I_FG)) {
        error("I_FG_notSparse","I_FG is not sparse");
    }

    if (mxGetM(I_FG) != mxGetM(F)) {
        error("I_FG_m","number of rows of I_FG (=%d) does not match number of rows F (=%d)",mxGetM(I_FG),mxGetM(F));
    }
}

void error(const char *id, const char *format, ...) {
    char errorMessage[1024];
    char fullId[128];

    snprintf(fullId, 128, "%s:%s", ERROR_ID_PREFIX, id);
    
    // ---- snprintf(fullId, 128, format, ...) ----
    va_list args;
    va_start(args, format);
    vsnprintf(errorMessage, 1024, format, args);
    va_end(args);
    
    mexErrMsgIdAndTxt(fullId, errorMessage);
}