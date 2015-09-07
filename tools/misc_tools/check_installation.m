function check_installation
% check whether all binaries are working properly



% check tmp dir
if strfind(getMTEXpref('tempdir',tempdir),' ')
  hline()
  disp('Warning: The path MTEX uses for temporary files');
  disp(['  tempdir = ''' getMTEXpref('tempdir') '''']);
  disp('contains white spaces!');
  disp(['Please change this in your <a href="matlab:edit mtex_settings.m">' ...
    'mtex_settings.m</a>!']);
  hline()
end

% check binaries
check_binaries;

% check mex binaries
check_mex;

% check for nfft bug
setMTEXpref('nfft_bug',0);
try
  setMTEXpref('nfft_bug',~checkNfftBug);
catch

end


end

% ------------ check for binaries --------------------------
function check_binaries

if fast_check_binaries, return; end

[th,rh] = polar(equispacedS2Grid('points',10));

th = fft_theta(th);
rh = fft_rho(rh);

gh = [reshape(rh,1,[]);reshape(th,1,[])];
r = [reshape(rh,1,[]);reshape(th,1,[])];

c = ones(size(th));

Al = ones(size(th));
setpref('mtex','binaries',false);

try

  f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
  assert(any(f));

  setpref('mtex','binaries',true);

catch %#ok<*CTCH>
  
  if ismac && strcmp(getMTEXpref('architecture'),'maci') % maybe it is a 64 bit mac
    try
      setMTEXpref('architecture','maci64');
      f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
      assert(any(f));
      setpref('mtex','binaries',true);
      return
    catch
      setMTEXpref('architecture','maci');
    end
  end

  hline()
  disp('  MTEX binary check failed!');
  disp(' ');
  disp('  The original error message was:');
  e = lasterror; %#ok<*LERR>
  disp(['  ',e.message]);

  disp(' ');
  disp('  Check the following options:');
  disp(['  * ' doclink('compilation','Compile') ' the binaries yourself.']);
  disp('  * Ask the maintainer for help!');
  hline()
end

end

function e = fast_check_binaries

e = false;

if ispc, mtex_ext = '.exe';else mtex_ext = '';end
binariespath = fullfile(mtex_path,'c','bin',getMTEXpref('architecture'));
binaries = {'pf2odf','pdf2pf','odf2pf','odf2fc','fc2odf'};

% check for existence
for k=1:numel(binaries)
  prg = fullfile(binariespath,binaries{k});
  if ~exist([prg mtex_ext],'file'),
    warning(['missing binary ' binaries{k} mtex_ext])
    return; 
  end
end

if ispref('mtex') && getpref('mtex','binaries')
  e = true;
  return
end

end

%    ----------- check mex files ---------------------------
function check_mex

% set mex/directory
mexpath = fullfile(mtex_path,'c','mex',getMTEXpref('architecture'));
addpath(mexpath,0);

% check for mex files
if fast_check_mex(mexpath), return;end

hline('-');
disp('Checking mex files failed!');

% check old mex version
if exist(fullfile(mexpath,'v7.1'),'dir')

  % change path
  rmpath(mexpath);
  addpath(fullfile(mexpath,'v7.1'));
  disp('> Trying now with older version.');
  if fast_check_mex(mexpath)
    disp('> Hurray - everythink works!')
    disp(' ');
    try
      copyfile(fullfile(mexpath,'v7.1','*.*'),mexpath,'f');
      % restore path
      rmpath(fullfile(mexpath,'v7.1'));
      addpath(mexpath);
    catch
      hline()
      disp('> Error while copying!')
      disp('> You should copy');
      disp(['  ' fullfile(mexpath,'v7.1')]);
      disp(' to ');
      disp(['  ', mexpath]);
      disp('> before starting the next session');
      hline()
      disp(' ');
    end
    return
  else
    disp('> Checking old mex files failed!');
    % restore path
    rmpath(fullfile(mexpath,'v7.1'));
    addpath(mexpath);
  end
end

disp('> Trying now to recompile mex files.');
opwd = pwd;
cd(fullfile(mtex_path,'c','mex'));
mex_install(mtex_path,false);
cd(opwd);

if ~fast_check_mex(mexpath)
  %   disp('> Hurray - everythink works!')
  % else
  hline()
  disp('  MTEX: Couldn''t get the mex files working!');
  disp('   ');
  disp('  The original error message was:');
  e = lasterror;
  disp(['  ' e.message]);

  disp(' ');
  disp('  Contact author for help!');
  hline()
end
hline('-')
end

% ----------------------------------------------------------------------

function e = fast_check_mex(mexpath)

e = false;

% check for existence
mex = {'quaternion_*','S1Grid_*','S2Grid_*','SO3Grid_*'};
for k=1:numel(mex)
  cfile = dir(fullfile(mexpath,'..', [mex{k} '*.c']));
  for c=1:numel(cfile)
    [a,cname] = fileparts(cfile(c).name);
    mexfile = fullfile(mexpath, [cname,'.' mexext]);
    if ~exist(mexfile,'file')
       warning(['missing mex-file ' [cname,'.' mexext]])
      return
    end
  end
end

if ispref('mtex') && ispref('mtex','mex')
  if getpref('mtex','mex')
    e = true;
    return
  end
end

try
  S3G = equispacedSO3Grid(crystalSymmetry,specimenSymmetry,'points',100);
  dot_outer(S3G,idquaternion,'epsilon',pi/4);
  e = true;
catch
  e = false;
end

setpref('mtex','mex',e);

end

% --------------------------------------------------------------

function out = checkNfftBug

  % set bandwidth
  L = 2;

  % set an orientation
  q = axis2quat(xvector+yvector,25*degree);

  % set a direction
  h = vector3d(1,2,3);

  % convert to export parameters
  g = Euler(q,'nfft');

  % set parameters
  c = 1;
  A = ones(1,L+1);

  % run NFSOFT
  D = call_extern('odf2fc','EXTERN',g,c,A); % conjugate(D)

  % extract result
  D = complex(D(1:2:end),D(2:2:end));

  l = 1;

  % rotate spherical harmonics manualy
  Y = sphericalY(l,h).'; % -> Y
  gY = sphericalY(l,q*h).'; % -> rotated Y

  % rotate spherical harmonics by matrix D
  D3 = reshape(D(2:10),3,3);

  TY = D3 * Y;

  % check whether spherical Y are rotated correctly by D
  out = sqrt(norm(TY - gY)) < 0.001;

end


% -----------------------------------------------------------------------


function hline(st)

if nargin < 1, st = '*'; end
disp(repmat(st,1,80));

end
