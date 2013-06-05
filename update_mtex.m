function update_mtex()

try
  newver = getlatesMTEXversion();
  
  vinst = ver2num(getMTEXpref('version'));
  vnew  = ver2num(newver);
  
  for k=1:numel(vinst)
    if vinst(k) >  vnew(k)
      break
    elseif vinst(k) ~= vnew(k)
      downloadAndInstallMTEX(newver);
      return
    end
  end
  
  disp(['no MTEX updates available, your version is ' newver])
catch e
  throwAsCaller(e)
end

end

function ver = getlatesMTEXversion()

dpage = urlread('https://code.google.com/p/mtex/downloads/list');

v = regexp(dpage,'(?<vers>mtex-\d+.\d+.\d+)','names');
v = sort(unique({v.vers}));
ver = v{end};

end

function downloadAndInstallMTEX(ver)

url  = ['https://mtex.googlecode.com/files/' ver  '.zip'];
thispath = fileparts(mfilename('fullpath'));
instpath = fileparts(thispath);

disp(['Latest available MTEX version is ' ver])
disp(' ')
disp(['   ' url])
disp(' ')
disp('Do you want to download and install the package to')
disp(' ')
disp(['   ' fullfile(instpath,ver)])
disp(' ')

reply = input('Y/N [Y]: ','s');

if strncmpi(reply,'y',1)
  
  disp(' ')
  disp(['Downloading ' ver '.zip to ' fullfile(instpath,ver)]);
  
  if exist(fullfile(instpath,ver),'dir')
    error('MTEX:update','The specified Folder already exists')
  end
  
  files = unzip(url,instpath);
  installfile = files{~cellfun('isempty',strfind(files,[ filesep 'install_mtex.m']))};
  
  disp(installfile);
  cd(fileparts(installfile));
  run(installfile);
  cd(thispath);
  
  disp('Successfully updated MTEX, please restart matlab');
end

end


function n = ver2num(v)

vs = '(?<major>\d+).(?<minor>\d+).(?<rev>\d+)';
n = structfun(@str2num,regexp(v,vs,'names'));

end