function mex_install(mtexpath,mexoptions)
% compiles all mex files for use with MTEX

global mtex_path;
if nargin == 0, mtexpath = mtex_path;end
mexpath = [mtexpath,'/c/mex/'];

places = {'S1Grid','S2Grid','SO3Grid','quaternion'};

if nargin < 2
  if strfind(computer,'64')
    mexoptions = '-largeArrayDims';
  else
    mexoptions = '-compatibleArrayDims';
  end
end

for p = 1:length(places)
  files = dir([mexpath places{p} '_*.c']);
  files = {files.name};
  for f = 1:length(files)
    if exist([mexpath,files{f}],'file')      
      disp(['compile ',files{f}]);
      mex(mexoptions,[mexpath,files{f}]);
    end
  end
  movefile([mexpath,places{p},'*.mex*'],...
           [mtexpath,'/geometry/@',places{p},'/private']);
end
