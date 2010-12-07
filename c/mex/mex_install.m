function mex_install(mtexpath,blas,varargin)
% compiles all mex files for use with MTEX

if nargin == 0, mtexpath = mtex_path;end
if nargin <= 1, blas = false;end
mexpath = fullfile(mtexpath,'c','mex');
mexfile = @(file)fullfile(mexpath,file);

%% check whether to set largeArrayDims option
if nargin <= 2 && newer_version(7.3)
  if strfind(computer,'64')
    varargin = {'-largeArrayDims'};
  else
    varargin = {'-compatibleArrayDims'};
  end
end

%% define the places
if blas
  places = {'mtimesx.c'};  
else
  places = strcat({'S1Grid','S2Grid','SO3Grid','quaternion'}, '_*.c');
end

%% compile all the files
for p = 1:length(places)
  files = dir(mexfile(places{p}));
  files = {files.name};
  for f = 1:length(files)
    if exist(mexfile(files{f}),'file')      
      disp(['... compile ',files{f}]);
      try
        if blas
          mex_blas(mexfile(files{f}),varargin{:},'-outdir',mexfile(get_mtex_option('architecture')));
        else
          mex(varargin{:},'-outdir',mexfile(get_mtex_option('architecture')),mexfile(files{f}));
        end
      catch %#ok<CTCH>
        disp(['Compiling ' mexfile(files{f}) ' failed!']);
      end
    end
  end
end
