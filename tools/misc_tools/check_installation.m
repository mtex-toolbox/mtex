function check_installation

global mtex_path;

%% check for mex files
try
  S2G = S2Grid('equispaced','points',10000);
  find(S2G,xvector);
catch
  warning('%s\n%s','--MTEX-- Error using mex files!',...
    'Recompile now mex files.');
  opwd = pwd;
  cd([mtex_path '/c/mex']);
  mex_install;
  cd(opwd);
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
