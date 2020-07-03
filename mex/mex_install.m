function mex_install(mtexpath,varargin)
% compiles all mex files for use with MTEX

if nargin == 0, mtexpath = mtex_path;end
mexpath = fullfile(mtexpath,'mex');
mexfile = @(file)fullfile(mexpath,file);

places = strcat({'S1Grid','S2Grid','SO3Grid','insidepoly'}, '_*.c');

% compile all the files
for p = 1:length(places)
  files = dir(mexfile(places{p}));
  files = {files.name};
  for f = 1:length(files)
    if exist(mexfile(files{f}),'file')
      disp(['... compiling ',files{f}]);
      try
        mex('-largeArrayDims',mexfile(files{f}));
      catch %#ok<CTCH>
        disp(['Compiling ' mexfile(files{f}) ' failed!']);
      end      
    end
  end
end
