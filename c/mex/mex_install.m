function mex_install(mtexpath)
% compiles all mex files for use with MTEX

global mtex_path;
if nargin == 0, mtexpath = mtex_path;end
mexpath = [mtexpath,'/c/mex/'];

places = {'S1Grid','S2Grid','SO3Grid'};
%places = {'SO3Grid'};
files = {'find','find_region','dist_region'};
%files = {'find_region','dist_region'};
%files = {'find.c','find_region.c'};

for p = 1:length(places)
  for f=1:length(files)
    if exist([mexpath,places{p},'_',files{f},'.c'],'file')
      mex('-largeArrayDims',[mexpath,places{p},'_',files{f},'.c']);
      movefile([mexpath,places{p},'_',files{f},'.mex*'],...
        [mtexpath,'/geometry/@',places{p},'/private']);
    end
  end
end


mex('-largeArrayDims',[mexpath,'/quaternion_mtimes.c']);
movefile([mexpath,'/quaternion_mtimes.mex*'],...
        [mtexpath,'/geometry/@quaternion/private']);
