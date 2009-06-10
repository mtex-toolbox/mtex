function mex_install(mtexpath,mexoptions)
% compiles all mex files for use with MTEX

if nargin == 0, mtexpath = mtex_path;end
mexpath = fullfile(mtexpath,'c','mex');
mexfile = @(file)fullfile(mexpath,file);

if nargin < 2
  if strfind(computer,'64')
    mexoptions = '-largeArrayDims';
  else
    mexoptions = '-compatibleArrayDims';
  end
end

places = strcat({'S1Grid','S2Grid','SO3Grid','quaternion'}, '_*.c');

for p = 1:length(places)
  files = dir(mexfile(places{p}));
  files = {files.name};
  for f = 1:length(files)
    if exist(mexfile(files{f}),'file')      
      disp(['>   compile ',files{f}]);
      if newer_version(7.3)
        mex(mexoptions,'-outdir',mexfile(get_mtex_option('architecture')),mexfile(files{f}));
      else
        mex('-outdir',mexfile(get_mtex_option('architecture')),mexfile(files{f}));
      end
    end
  end
%  try
%    movefile([mexpath,places{p},'*.mex*'],...
%      [mtexpath,'/geometry/@',places{p},'/private']);
%  catch
%    disp('There was an error while moving the mex files! Please move the files manualy')
%  end
end
