function check_installation
% check whether all binaries are working properly

% check basic mex files
try
  fast_check_mex
catch 

  hline('-');
  disp(' ');
  disp('Checking mex files failed!');

  disp('> Trying now to recompile mex files.');
  opwd = pwd;
  cd(fullfile(mtex_path,'mex'));
  mex_install(mtex_path,false);
  cd(opwd);
  
  try
    fast_check_mex
    disp('> Hurray - everythink works!')
  catch ME
    hline()
    disp('  MTEX: Couldn''t get the mex files working!');
    disp('   ');
    disp('  The original error message was:');
    disp(' ');
    disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) )
    disp(' ');
    disp(' Please have a look at https://mtex-toolbox.github.io/installation')
    disp(' or ask in the forum https://github.com/mtex-toolbox/mtex/discussions for help.');
  
    hline()
  end
  hline('-');
end

% check nfft
try 
  check_NFSFT
  check_NSOFT  
  return
catch
  disp(' ');
  hline()
  disp(' ');
  disp('  MTEX: Error running NFFT with openMP - I''m going to try it without openmp!');
  rmpath([mtex_path filesep 'extern' filesep 'nfft_openMP'])
  addpath([mtex_path filesep 'extern' filesep 'nfft'])
end

try 
  check_NFSFT
  check_NSOFT
catch ME
   
  disp(' ');
  disp('  MTEX: Error running NFFT without openMP!');
  disp('   ');
    
  disp(' I did not get NFFT working. This restricts the functionality of MTEX.')
  disp(' To overcome this restriction you may need to compile the NFFT your own.');
  if ismac
    disp(' Please have a look at https://mtex-toolbox.github.io/installation for possible workarounds')
    disp(' or ask in the forum https://github.com/mtex-toolbox/mtex/discussions for help.');
  else
    disp(' Please have a look at https://github.com/mtex-toolbox/mtex/blob/develop/extern/nfft_openMP/readme.md');
    disp(' or ask in the forum https://github.com/mtex-toolbox/mtex/discussions for help.');
  end
  disp(' ');
  disp('  The original error message was:');
  disp(' ');
  disp( getReport( ME, 'extended', 'hyperlinks', 'on' ) )
  
  hline()
end

end

function check_NFSFT

  f = @(x) x.theta;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',12);
  assert(abs(f(xvector) - sF.eval(xvector))<1e-5);

end

function check_NSOFT

ori = orientation.rand(100,crystalSymmetry);
odf = calcDensity(ori,'Fourier','bandwidth',12);
odf.eval(ori);

end


function fast_check_mex

mexpath = [mtex_path filesep 'mex'];

places = {'geometry/@S1Grid/private/S1Grid_',...
  'geometry/@S2Grid/private/S2Grid_',...
  'geometry/@SO3Grid/private/SO3Grid_',...
  'extern/insidepoly/',...
  'SO3Fun/@SO3FunHarmonic/private/adjoint',...
  'SO3Fun/@SO3FunHarmonic/private/representationbased'};

for k=1:numel(places)
  cfile = dir(fullfile(mtex_path,[places{k} '*.c']));
  for c=1:numel(cfile)
    [~,cname] = fileparts(cfile(c).name);
    mexfile = fullfile(mexpath, [cname,'.' mexext]);
    if ~exist(mexfile,'file')
      error(['missing mex-file ' [cname,'.' mexext]])
    end
  end
end

S3G = equispacedSO3Grid(crystalSymmetry,specimenSymmetry,'points',100);
dot_outer(S3G,quaternion.id,'epsilon',pi/4);

end


function hline(st)

if nargin < 1, st = '*'; end
fprintf('\n');
disp(repmat(st,1,80));

end
