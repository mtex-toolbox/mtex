function check_installation
% check whether all binaries are working properly

% check nfft
if ~check_nfft
  
  rmpath([mtex_path filesep 'extern' filesep 'nfft_openMP'])
  addpath([mtex_path filesep 'extern' filesep 'nfft'])
  
  hline()
  if check_nfft
    
    disp(' ');
    disp('  MTEX: Error running NFFT with openmp - I''m going to use it without openmp!');
    
  else

    disp(' ');
    disp('  MTEX: Error running NFFT!');
    disp('   ');
    disp('  The original error message was:');
    e = lasterror;
    disp(['  ' e.message]);

    disp(' ');
    disp(' I did not get NFFT working. This restricts the functionality of MTEX.')
    disp(' To overcome this restriction you may need to compile the NFFT your own.');
    if ismac
      disp(' Please have a look at https://mtex-toolbox.github.io/installation for possible workarounds')
    else
      disp(' Please have a look at https://github.com/mtex-toolbox/mtex/blob/develop/extern/nfft_openMP/readme.md');
    end
        
  end
  hline()
end
    
% check mex 
check_mex;

end


% -------- check nfft

function e = check_nfft

e = 0;
try
  % check NFSFT
  f = @(x) x.theta;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',12);
  assert(abs(f(xvector) - sF.eval(xvector))<1e-5);
  
  % check NFSOFT
  ori = orientation.rand(100,crystalSymmetry);
  odf = calcDensity(ori,'Fourier','bandwidth',12);
  odf.eval(ori);
  e = 1;
end
end

% ----------- check mex files ---------------------------
function check_mex

% check for mex files
if fast_check_mex, return;end

hline('-');
disp('Checking mex files failed!');

disp('> Trying now to recompile mex files.');
opwd = pwd;
cd(fullfile(mtex_path,'mex'));
mex_install(mtex_path,false);
cd(opwd);

if fast_check_mex
  disp('> Hurray - everythink works!')
else
  hline()
  disp('  MTEX: Couldn''t get the mex files working!');
  disp('   ');
  disp('  The original error message was:');
  e = lasterror;
  disp(['  ' e.message]);

  disp(' ');
  disp(' Please have a look at https://mtex-toolbox.github.io/installation')
  disp(' or ask in the forum https://groups.google.com/forum/#!forum/mtexmail for help.');
  
  hline()
end
hline('-')
end

% ----------------------------------------------------------------------

function e = fast_check_mex

e = false;
mexpath = [mtex_path filesep 'mex'];

% check for existence of the files
mex = {'quaternion_*','S1Grid_*','S2Grid_*','SO3Grid_*'};
for k=1:numel(mex)
  cfile = dir(fullfile(mexpath, [mex{k} '.c']));
  for c=1:numel(cfile)
    [~,cname] = fileparts(cfile(c).name);
    mexfile = fullfile(mexpath, [cname,'.' mexext]);
    if ~exist(mexfile,'file')
       warning(['missing mex-file ' [cname,'.' mexext]])
      return
    end
  end
end

try
  S3G = equispacedSO3Grid(crystalSymmetry,specimenSymmetry,'points',100);
  dot_outer(S3G,quaternion.id,'epsilon',pi/4);
  e = true;
catch
  e = false;
end

end


function hline(st)

if nargin < 1, st = '*'; end
fprintf('\n');
disp(repmat(st,1,80));

end
