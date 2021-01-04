#include "buffer.c"

typedef struct S1Grid_ {

  double *x;
  int n;
  double min,p;

} S1Grid;

void S1Grid_init(S1Grid S1G[], double *x, int n, double min, double p)
{
  S1G->x = x;
  S1G->n = n;
  S1G->min = min;
  S1G->p = p;
}

void S1Grid_print(S1Grid S1G[])
{
  printf("n: %d min: %.4e p: %.4e \n",S1G->n,S1G->min,S1G->p);
}

void S1Grid_finalize(S1Grid S1G[])
{
}


static int S1Grid_find_lower(S1Grid S1G[], double x)
{
  int a,b,c;
  a = 0;
  b = S1G->n-1;

  if (S1G->x[b]<=x) return b;
  if (S1G->x[0]>x) return -1;
  
  while (b - a > 1) {
      
    c = (a+b)/2;

    if (x >= S1G->x[c]) a = c; else b = c; 
  }
  return a;
}

static int S1Grid_find_greater(S1Grid S1G[], double x)
{
  int a,b,c;
  a = 0;
  b = S1G->n-1;
  
  if (S1G->x[0]>=x) return 0;
  if (S1G->x[b]<x) return b+1;

  while (b - a > 1) {
      
    c = (a+b)/2;
    if (x > S1G->x[c]) a = c; else b = c; 
  }
  return b;
}

static int S1Grid_find(S1Grid S1G[], double x)
{
  int a,b,c;
  a = 0;
  b = S1G->n-1;
  
  if (S1G->p>0) { /* periodic case*/
    
    x = MOD3(x,S1G->p,S1G->min);    
    if (x < S1G->x[a] && S1G->x[a] - x >= x + S1G->p - S1G->x[b])
      return b;

    if (x > S1G->x[b] && S1G->p - x + S1G->x[a] <= x - S1G->x[b])
      return a;
  }

  while (b - a > 1) {
      
    c = (a+b)/2;

    if (x > S1G->x[c])
      a = c;
    else
      b = c; 
  }
   
  if (x - S1G->x[a] < S1G->x[b] - x)
    return a;
  else
    return b;

}


void S1Grid_find_region(S1Grid S1G[], double x, double e, buffer ind[])
{

  int minp, maxp;

  if (S1G->p>0) { /* periodic case*/

    x = MOD3(x,S1G->p,S1G->min);
    minp = S1Grid_find_greater(S1G,MOD3(x-e,S1G->p,S1G->min));
    maxp = S1Grid_find_lower(S1G,MOD3(x+e,S1G->p,S1G->min));

    /*printf("%.4e %.4e %.4e",x,e,S1G->min + S1G->p);*/
    if ((x - e >= S1G->min) && (x + e < S1G->min + S1G->p))
      buffer_append(ind,minp,maxp);
    else if ((x - e <= S1G->min) && (x + e >= S1G->min + S1G->p))
       buffer_append(ind,0,S1G->n-1);
    else {
      buffer_append(ind,0,maxp);
      buffer_append(ind,MAX(minp,maxp+1),S1G->n-1);
    }

  } else   /*non periodic case*/
    buffer_append(ind,
		  S1Grid_find_greater(S1G,x-e),
		  S1Grid_find_lower(S1G,x+e));
}
