/**
 * @file   pio.h
 * @author ralf
 * @date   Thu Oct 12 07:05:54 2006
 * 
 * @brief library to read and write parameter files 
 * 
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <complex.h>

typedef struct param_file_type_{
  /* identifier in parameter file */
  char *identifier;        
  /* like for 'printf' if includet in parameter file or keyword 'DATA_FILE' */
  char *format;            
  /* reference to variable that takes the data */
  void *data;
  /* reference to variable that takes the number of data */
  /* NULL for single input */
  int  *ldata;
  /* size of datatype | 0 for string input */
  int  byte_size;
} param_file_type;

FILE *check_fopen(char *fname,char *mode);

/* function to read a whole parameter file and to allocate the memory */
int read_param_file(FILE *f_param, param_file_type *in, int Nin,int del_files);


