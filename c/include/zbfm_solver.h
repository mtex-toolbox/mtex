#include <zbfm.h>
#include <odf.h>
#include <time.h>

#define ODF_SAVE                (1U << 5)
#define RP_VALUES               (1U << 6)
#define FORCE_ITER_MAX          (1U << 7)
#define ODF_TEST           	(1U << 8)



typedef struct zbfm_solver_plan_{

  unsigned int flags;

  zbfm_plan *zbfm;
  odf_plan  *odf;

  int iter;
  int iter_max;
  int iter_min;

  double error_iter;
  double error_max;

  double descent_iter;
  double descent_max;
  double descent_min;

  char file_name[BUFSIZ];
 
} zbfm_solver_plan;


void zbfm_solver_init(zbfm_solver_plan *ths,zbfm_plan *zbfm,unsigned int flags,char *fn);

void zbfm_solver_iterate(zbfm_solver_plan *ths);

void zbfm_solver_finalize(zbfm_solver_plan *ths);

void zbfm_solver_save(zbfm_solver_plan *ths);
