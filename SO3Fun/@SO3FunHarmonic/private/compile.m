

% Use MultiCore Programming (openmp) for Linux and Windows

if isunix && ~ismac
  options = {'CFLAGS=\$CFLAGS -fopenmp','LDFLAGS=\$LDFLAGS -fopenmp'};
elseif ispc
  options = {'COMPFLAGS=$COMPFLAGS /openmp'};
else
  options={};
end

mex(options{:},'-R2018a',cFile);
