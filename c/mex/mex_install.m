function mex_install(mtexpath,varargin)
% compiles all mex files for use with MTEX

if nargin == 0, mtexpath = mtex_path;end
mexpath = fullfile(mtexpath,'c','mex');
mexfile = @(file)fullfile(mexpath,file);

% check whether to set largeArrayDims option
if nargin <= 2 && newer_version(7.3)
  if strfind(computer,'64')
    varargin = {'-largeArrayDims'};
  else
    varargin = {'-compatibleArrayDims'};
  end
end

places = strcat({'S1Grid','S2Grid','SO3Grid'}, '_*.c');

% compile all the files
for p = 1:length(places)
  files = dir(mexfile(places{p}));
  files = {files.name};
  for f = 1:length(files)
    if exist(mexfile(files{f}),'file')
      disp(['... compile ',files{f}]);
      try
        mex(varargin{:},'-outdir',mexfile(getMTEXpref('architecture')),mexfile(files{f}));
      catch %#ok<CTCH>
        disp(['Compiling ' mexfile(files{f}) ' failed!']);
      end      
    end
  end
end
