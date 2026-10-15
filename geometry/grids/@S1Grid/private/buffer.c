#include <math.h>
#include <mex.h>
#include <stdio.h>

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

#if !defined(MOD)
#define	MOD(A, B)	((A)-floor((A)/(B))*(B))
#endif

#if !defined(MOD3)
#define	MOD3(A, B, C)	((A)-floor((A-C)/(B))*(B))
#endif

#if !defined(ROUND)
#define	ROUND(A)	(floor((A)+0.5))
#endif

#if !defined(MOD0)
#define	MOD0(A, B)	((A)-ROUND((A)/(B))*(B))
#endif

#if !defined(DIST)
#define	DIST(A, B)	(MIN(B-A,A))
#endif

#if !defined(MWSIZE_MAX)
typedef	int mwSize;
typedef	int mwIndex;
typedef	int mwSignedIndex;
#endif


typedef struct buffer_ {
  
  int *data; 
  int offset;
  int used;
  int max;
      
} buffer;

void print_int(int *x,int nx){
  int i;
  
  for (i=0;i<nx;i++){
    printf("%d ",x[i]);
  }
  printf("\n");
}

void print_double(double *x,int nx){
  int i;
  
  for (i=0;i<nx;i++){
    printf("%.4e ",x[i]);
  }
  printf("\n");
}

void buffer_init(buffer *ths, mwSize N) {
  ths->data = (int*) mxCalloc(N,sizeof(int));
  ths->offset = 0;
  ths->max = N;
  ths->used = 0;
}

void buffer_print(buffer *ths) {
  print_int(ths->data,ths->used);
}

void buffer_reset(buffer *ths) {
  ths->used = 0;
  ths->offset = 0;
}

void buffer_set_offset(buffer *ths,int offset) {
  ths->offset = offset;
}

void buffer_finalize(buffer *ths) {
  mxFree(ths->data);
}

void buffer_append(buffer *ths, int min, int max) {
  int i;
  
  if (min > max) return;
  if (1 + max - min > ths->max - ths->used) {
    i = MAX(2*ths->used,ths->used + 1 + max - min);
    ths->data = (int*) mxRealloc(ths->data,sizeof(int) * i);
    ths->max = i;
  }

  for (i=min;i<=max;i++) {
    /*printf("<%d - %d>",ths->used + i - min + 1,i);*/
    ths->data[ths->used + i - min] = ths->offset + i;
  }
  ths->used += 1 + max - min;
}

typedef struct double_buffer_ {
  
  double *data; 
  int used;
  int max;
      
} double_buffer;


void double_buffer_init(double_buffer *ths, mwSize N) {
  ths->data = (double*) mxCalloc(N,sizeof(double));
  ths->max = N;
  ths->used = 0;
}

void double_buffer_reset(double_buffer *ths) {
  ths->used = 0;
}

void double_buffer_finalize(double_buffer *ths) {
  mxFree(ths->data);
}

void double_buffer_reserve(double_buffer *ths, int n) {
  
  int i;
  
  if (n > ths->max) {
    i = MAX(n,(ths->max * 5)/4);
    /*printf("%d ",i);*/
    ths->data = (double*) mxRealloc(ths->data,sizeof(double) * i);
    ths->max = i;
  }

}
