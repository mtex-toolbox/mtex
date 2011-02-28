function mex_blas(fileName,varargin)
% compile files including the blas library

%% setup BLAS Library
% Construct full file name of libmwblas.lib and libmwlapack.lib. Note that
% not all versions have both files. Earlier versions only had the lapack
% file, which contained both blas and lapack routines.
if ispc
  
  % read mexopts.bat file
  file = file2cell([prefdir '\mexopts.bat']);

  % locate compiler
  myCompiler = regexp(file,'COMPILER=(\w*)','tokens');
  myCompiler = [myCompiler{:}];

  % known compilers and libdirs
  compiler = {'lcc','cl','bcc32','icl','gcc','wc1386'};
  libdir = {'lcc','microsoft','microsoft','microsoft','microsoft','microsoft'};
  
  pos = strcmp(compiler,char(myCompiler{1}));
  if any(pos)
    libdir = libdir{pos};
  else
    libdir = libdir{end};
  end
  
  lib_blas = fullfile(matlabroot,'extern','lib',computer('arch'),libdir,'libmwblas.lib');
  
elseif ismac
  
  lib_blas = [matlabroot filesep 'bin' filesep computer('arch') filesep 'libmwblas.dylib'];
  varargin = [{'-DDEFINEUNIX'},varargin];
  
else
  
  lib_blas = [matlabroot filesep 'bin' filesep computer('arch') filesep 'libmwblas.so'];
  varargin = [{'-DDEFINEUNIX'},varargin];
  
end

% check BLAS library is in place - if not look for libmwlapack
if isempty(dir(lib_blas)), lib_blas = strrep(lib_blas,'blas','lapack'); end

% check BLAS library is in place
if isempty(dir(lib_blas)), error('... Could not find BLAS library!'); end

%% Do the compile
try
  mex(varargin{:},fileName,lib_blas);  
catch %#ok<CTCH>
  try
    varargin = [{'-DDEFINEMWSIZE','-DDEFINEMWSIGNEDINDEX'},varargin];
    mex(varargin{:},fileName,lib_blas);    
  catch %#ok<CTCH>    
    error('')
  end
end
