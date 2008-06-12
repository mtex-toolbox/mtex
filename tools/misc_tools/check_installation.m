function check_installation

global mtex_path;

%% check for mex files
try
  fast_check_mex;
catch
  warning('%s\n','--MTEX-- Error using mex files!');

  try
    mtex_assert(exist([mtex_path '/c/mex/v7.1'],'dir'));
    rmpath([mtex_path '/c/mex']);
    addpath([mtex_path '/c/mex/v7.1']);
    disp('Trying now with older version.');
    fast_check_mex;    
    disp('Hurray - everythink works!')
    try
      copyfile([mtex_path '/c/mex/v7.1/*.*'],[mtex_path '/c/mex'],'f');
      rmpath([mtex_path '/c/mex/v7.1']);
      addpath([mtex_path '/c/mex']);
    catch
      disp('Error while copying!')
      disp('You should copy');
      disp([' ' mtex_path '/c/mex/v7.1']);
      disp(' to ');
      disp([' ', mtex_path '/c/mex']);
      disp('Befor starting the next session');
    end    
  catch
    
    warning('%s\n','--MTEX-- Error using mex files!');
    disp('Recompile now mex files.');
    rmpath([mtex_path '/c/mex/v7.1']);
    addpath([mtex_path '/c/mex']);
    opwd = pwd;
    cd([mtex_path '/c/mex']);
    mex_install;
    cd(opwd);
    
    try
      fast_check_mex;
      disp('Hurray - everythink works!')
    catch
      warning('%s\n%s','--MTEX-- Error using mex files!',...
      'Contact author for help!');
    end

  end
end

%% check for binaries

try
  [th,rh] = polar(S2Grid('equispaced','points',10));
	
  th = fft_theta(th);
  rh = fft_rho(rh);

  gh = [reshape(rh,1,[]);reshape(th,1,[])];
  r = [reshape(rh,1,[]);reshape(th,1,[])];

  c = ones(10,1);

  Al = ones(10,1);
  
  f = run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al);
  mtex_assert(any(f));

catch
  
  warning('%s\n%s','--MTEX-- Incompatiple binaries!',...
    'Download the binaries that corresponds to your system, recompile the binaries yourself, or ask the maintainer!');
    
end


function fast_check_mex

S3G = SO3Grid(100,symmetry,symmetry);
dot_outer(S3G,idquaternion,'epsilon',pi/10);
