BSXFUN for MATLAB versions prior to R2007a.

To use bsxfun:

1. Place the contents of this zip archive into a directory on your
   MATLAB path.

2. From the MATLAB prompt type "make_bsx_mex" and return.  This will
   build the mex functions using the compiler you have selected with
   "mex -setup" (run first, if necessary).

3. That's it!  Now you can use the function, bsxfun, in your older version
   of MATLAB.

If you can't get the mex functions to work you can still use bsxfun, but
you won't get the speed advantage of the supported mex functions.
