/***************************************************************/
/******** library to read and write parameter files ************/
/************* author: Ralf Hielscher 2006 *********************/
/***************************************************************/

#include <pio.h>
#include <helper.h>
#include <unistd.h>

FILE *check_fopen(char *fname,char *mode){
  FILE *fid;
  fid = fopen(fname,mode);
  if (fid==NULL) {
    printf("Error! Could not open file <%s>\n",fname);
    abort();
  }
  return(fid);
}

long fsize(FILE *f){
  long s;

  fseek(f,0,SEEK_END);
  s = ftell(f);
  rewind(f);
  return(s);
}

int read_param_file(FILE *f_param,
		param_file_type *in,
		int Nin,int del_files){
  int i,l;
  FILE *f;
  void *buff;
  char line[BUFSIZ];
  char *lp;
  char identifier[BUFSIZ];
  char f_name[BUFSIZ];
  int  found[Nin];


  buff = malloc(BUFSIZ);
  

  for (i=0;i<Nin;i++) {
    found[i]=0;
    if (in[i].ldata != NULL)
      in[i].ldata[0] = 0;
  }
  
  while (fgets(line,BUFSIZ,f_param) != NULL) {
    sscanf(line,"%s:",identifier);
    lp = (char *)&line + strlen(identifier)+1;

    for (i=0;i<Nin;i++) 
      if (!strcmp(identifier,in[i].identifier)) {

	found[i]++;
	if (!strcmp(in[i].format,"DATA_FILE")) { /* read input from seperate data file */
	  	 
	  sscanf(lp,"%s",f_name); lp = (char *)&line + strlen(f_name);
	  f = check_fopen(f_name,"rb");

	  in[i].ldata[0] = fsize(f) / in[i].byte_size; 
	  
	  *(void**)in[i].data = malloc(in[i].ldata[0] * in[i].byte_size);
	  fread(*(char **)in[i].data,in[i].byte_size,in[i].ldata[0],f);
	  fclose(f);

	  /* clear file*/
	  if (del_files) 
	    unlink(f_name);
	  else /* output */
	    {
	    printf("%s read from file %s, size: %d x %d byte\n",
		   in[i].identifier,f_name,in[i].ldata[0],in[i].byte_size);
	    /*print_double(stdout,*(double **)in[i].data,in[i].ldata[0]);*/
	    /*printf("\n");*/
	    }
	} else if (in[i].ldata==NULL) { /* read single formated input*/
	  
	  sscanf(lp,in[i].format,buff);
	  
	  if (in[i].byte_size==0)
	    strcpy(in[i].data,buff);
	  else
	    memcpy(in[i].data,buff,in[i].byte_size);
	  
	  if (!del_files) { /* output */
	    printf("%s ",in[i].identifier);
	    if (in[i].byte_size==0)
	      printf(in[i].format,in[i].data);
	    else if (in[i].byte_size<8)
	      printf(in[i].format,*(int*)in[i].data);
	    else
	      printf(in[i].format,*(double*)in[i].data);
	    printf("\n");
	  }
	} else {  /* read formated input*/
	  
	  lp = strtok(lp, " \t;:,");
	  l = 0;
	  while (lp != NULL) {
	    if (sscanf(lp,in[i].format,buff+l)==1){
	      in[i].ldata[0]++;
	      l += in[i].byte_size;
	    }
	    lp = strtok (NULL, " \t;:,");
	  }
	  
	  *(void**)in[i].data = malloc(l);
	  memcpy(*(void**)in[i].data,buff,l);
	  if (!del_files) { /* output */
	    printf("%s ",in[i].identifier);
	    if (in[i].byte_size<8)
	      print_int(stdout,*(void**)in[i].data,in[i].ldata[0]);
	    else
	      print_double(stdout,*(void**)in[i].data,in[i].ldata[0]);
	    printf("\n");
	  }
	}
      } 
  }
  free(buff);
  for (i=0,l=0;i<Nin;i++) l += found[i]>0;
  if (!del_files) /* output */
    printf("assigned parameters %d of %d requested\n",l,Nin);
  return(l);
}
