function check_installation

global mtex_tmppath;
if strfind(mtex_tmppath,' ')
  disp('--------------------------------------------------')
  disp('Warning: The path MTEX uses for temporary files');
  disp(['  mtex_tmppath = ''' mtex_tmppath '''']);
  disp('contains white spaces!');
  disp(['Please change this in your <a href="matlab:edit startup_mtex">' ...
    'startup_mtex.m</a>!']);
  disp('--------------------------------------------------')
end

check_mex;
check_binaries;


%%----------- check mex files ---------------------------
function check_mex

global mtex_path;

% check for mex files
if fast_check_mex, return;end
        
disp('Checking mex files failed!');
disp('--------------------------');

% check old mex version
if exist([mtex_path '/c/mex/v7.1'],'dir')
    
  % change path  
  rmpath([mtex_path '/c/mex']);
  addpath([mtex_path '/c/mex/v7.1']);
  disp('> Trying now with older version.');
  if fast_check_mex
    disp('> Hurray - everythink works!')
    try
      copyfile([mtex_path '/c/mex/v7.1/*.*'],[mtex_path '/c/mex'],'f');
      % restore path
      rmpath([mtex_path '/c/mex/v7.1']);
      addpath([mtex_path '/c/mex']);
    catch
      disp('--------------------------------------------------')
      disp('> Error while copying!')
      disp('> You should copy');
      disp(['  ' mtex_path '/c/mex/v7.1']);
      disp(' to ');
      disp(['  ', mtex_path '/c/mex']);
      disp('> before starting the next session');
      disp('--------------------------------------------------')
    end    
    return
  else
    disp('> Checking old mex files failed!');
    % restore path
    rmpath([mtex_path '/c/mex/v7.1']);
    addpath([mtex_path '/c/mex']);   
  end
end   

disp('> Trying now to recompile mex files.');
opwd = pwd;
cd([mtex_path '/c/mex']);
mex_install;
cd(opwd);    
    
if fast_check_mex
  disp('> Hurray - everythink works!')
else
  disp('--------------------------------------------------')
  disp('MTEX: Couldn''t get the mex files working!');
  disp(' ');
  disp('The original error message was:');
  disp(' ');
  e = lasterror;
  disp(e.message);
  
  disp(' ');
  disp('Contact author for help!');
  disp('--------------------------------------------------')
end


%%------------ check for binaries --------------------------
function check_binaries

global mtex_path;

[th,rh] = polar(S2Grid('equispaced','points',10));
	
th = fft_theta(th);
rh = fft_rho(rh);

gh = [reshape(rh,1,[]);reshape(th,1,[])];
r = [reshape(rh,1,[]);reshape(th,1,[])];

c = ones(10,1);

Al = ones(10,1);

try
    
  f = run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al);
  mtex_assert(any(f));

catch
  
  disp('--------------------------------------------------');
  disp('MTEX binary check failed!');  
  disp(' ');
  disp('The original error message was:');
  disp(' ');
  e = lasterror;
  disp(e.message);
  
  disp(' ');
  disp('Check the following options:');  
  disp('* Download the binaries that corresponds to your system.');
  disp('* Compile the binaries yourself.');
  disp('* Ask the maintainer for help!');
  disp('--------------------------------------------------');
end


function e = fast_check_mex

e = 1;
try
  S3G = SO3Grid(100,symmetry,symmetry);
  dot_outer(S3G,idquaternion,'epsilon',pi/10);
catch
  e = 0;  
end
