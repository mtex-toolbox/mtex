
// mex TriplepointSegments.c -R2018a

#include <string.h>
#include <stdarg.h>
#include "mex.h"

// maximum number of neighbors of a vertex
#define MAX_NEIGHBORS ( 8 )

#define ERROR_ID_PREFIX ( "MTEX:TriplepointSegments" )

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

    IntStack startPoints;

    IntStack s;// segments
    IntStack sP;// segmentPoints (indice)
    IntStack sf;// segments (faces)
    IntStack sfF;// segmentFaces (indices)
    IntStack sfD;// segment face directions

    int* F_used;
};
typedef struct WorkingData WorkingData;


// ------------ function headers ------------

void calcTriplepointSegments(const mxArray *F, const mxArray *V, mxArray **s, mxArray **sP, mxArray **sf, mxArray **sfF, mxArray **sfD);

void buildNeighborList(WorkingData* w);

void calcSegmentsStartingFrom(WorkingData *w, int startPoint);

void calcSegmentStartingFrom(WorkingData *w, int startPoint, int nIndex);

static inline void push(IntStack *intStack, int value);

void initIntStack(IntStack *intStack, int maxSize);

void error(const char *id, const char *format, ...);





// ------------ function implementations ------------

void mexFunction(int nOutputs, mxArray *outputs[], int nInputs, const mxArray *inputs[]) {
    if (nInputs != 2) {
        error("nInputs","2 Inputs required! nInputs=%d",nInputs);
    }
    if (nOutputs != 5) {
        error("nOutputs","5 Outputs required! nOutputs=%d",nOutputs);
    }

    calcTriplepointSegments(inputs[0], inputs[1], &outputs[0], &outputs[1], &outputs[2], &outputs[3], &outputs[4]);
}

void calcTriplepointSegments(const mxArray *F, const mxArray *V, mxArray **s, mxArray **sP, mxArray **sf, mxArray **sfF, mxArray **sfD) {    
    WorkingData w;
    
    // ------ read input data -----

    w.F_M = mxGetM(F);
    w.F_doubles = mxGetDoubles(F);

    w.V_M = mxGetM(V);// number of vertices

    // ------ build data structures ------

    buildNeighborList(&w);

    initIntStack(&(w.startPoints), w.V_M);
    
    // calculate if segment start point
    for (int i = 0; i < w.V_M; i++) {
        if (w.VNSize[i] != 2 && w.VNSize[i] != 0) {
            // if number of neighbours not 2 or 0: start point
            push(&(w.startPoints), i);
            //printf("segmentstart: %d (%d)\n",i,w.VNSize[i]);
        }
    }
    
    initIntStack(&(w.s), w.F_M + 1);
    initIntStack(&(w.sP), w.F_M*2);
    initIntStack(&(w.sf), w.F_M + 1);
    initIntStack(&(w.sfF), w.F_M);
    initIntStack(&(w.sfD), w.F_M);

    w.F_used = mxMalloc(sizeof(int)*w.F_M);
    memset(w.F_used, 0, sizeof(int)*w.F_M);

    // triple points
    for (int i = 0; i < w.startPoints.index; i++) {
        calcSegmentsStartingFrom(&w, w.startPoints.buffer[i]);
    }

    // remaining: circles
    for (int i = 0; i < w.F_M; i++) {
        if (w.F_used[i] == 0) {
            calcSegmentStartingFrom(&w, (int)(w.F_doubles[i] - 1), 0);
        }
    }

    // close data structure
    push(&(w.s), w.sP.index);
    push(&(w.sf), w.sfF.index);
    
    // ------ generate output data ------

    *s = mxCreateDoubleMatrix(w.s.index, 1, mxREAL);
    double* s_doubles = mxGetDoubles(*s);
    for (int i = 0; i < w.s.index; i++) {
        s_doubles[i] = w.s.buffer[i] + 1;
    }

    *sP = mxCreateDoubleMatrix(w.sP.index, 1, mxREAL);
    double* sP_doubles = mxGetDoubles(*sP);
    for (int i = 0; i < w.sP.index; i++) {
        sP_doubles[i] = w.sP.buffer[i] + 1;
    }

    *sf = mxCreateDoubleMatrix(w.sf.index, 1, mxREAL);
    double* sf_doubles = mxGetDoubles(*sf);
    for (int i = 0; i < w.sf.index; i++) {
        sf_doubles[i] = w.sf.buffer[i] + 1;
    }

    *sfF = mxCreateDoubleMatrix(w.sfF.index, 1, mxREAL);
    double* sfF_doubles = mxGetDoubles(*sfF);
    for (int i = 0; i < w.sfF.index; i++) {
        sfF_doubles[i] = w.sfF.buffer[i] + 1;
    }

    *sfD = mxCreateDoubleMatrix(w.sfD.index, 1, mxREAL);
    double* sfD_doubles = mxGetDoubles(*sfD);
    for (int i = 0; i < w.sfD.index; i++) {
        sfD_doubles[i] = w.sfD.buffer[i];
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

void calcSegmentsStartingFrom(WorkingData *w, int startPoint) {
    //printf("calcSegmentsStartingFrom(w, %d)\n",startPoint);
    for (int i = 0; i < w->VNSize[startPoint]; i++) {
        int face = w->VNFindex[startPoint*MAX_NEIGHBORS + i];
        if (w->F_used[face] == 0) {
            calcSegmentStartingFrom(w, startPoint, i);
        }
    }
}

void calcSegmentStartingFrom(WorkingData *w, int startPoint, int nIndex) {
    //printf("calcSegmentStartingFrom(w, %d, %d)\n",startPoint,nIndex);
    push(&(w->s), w->sP.index);
    push(&(w->sf), w->sfF.index);

    // first Point
    push(&(w->sP), startPoint);
    //printf("first Point: %d\n",startPoint);

    // first Face
    int face = w->VNFindex[startPoint*MAX_NEIGHBORS + nIndex];
    int faceDirection = (int)(w->F_doubles[face]) == startPoint + 1;
    push(&(w->sfF), face);
    push(&(w->sfD), faceDirection);

    w->F_used[face] = 1;// use face

    // next Points:
    int currentPoint = w->VN[startPoint*MAX_NEIGHBORS + nIndex];
    while (1) {
        push(&(w->sP), currentPoint);
        //printf("currentPoint: %d\n",currentPoint);

        if (w->VNSize[currentPoint] != 2) {
            // if point has not 2 neigbours: end of segment
            return;
        }

        face = w->VNFindex[currentPoint*MAX_NEIGHBORS];// first option
        nIndex = 0;

        if (w->F_used[face]) {
            face = w->VNFindex[currentPoint*MAX_NEIGHBORS + 1];// second option
            nIndex = 1;
        }

        if (w->F_used[face]) {
            return;// if both faces already used: stop
        }

        faceDirection = (int)(w->F_doubles[face]) == currentPoint + 1;
        push(&(w->sfF), face);
        push(&(w->sfD), faceDirection);

        w->F_used[face] = 1;// use face

        currentPoint = w->VN[currentPoint*MAX_NEIGHBORS + nIndex];// next point
    }
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