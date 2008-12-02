function startup_mtex
% init MTEX session
%
% 
%

%% start MTEX
disp('initialize MTEX ...');

% path to this function to be considered as the root of the MTEX
% installation 
local_path = fileparts(mfilename('fullpath'));


%% needs installation ?
install_mtex(local_path);


%% setup search path 
toadd = {'',...
  'qta','qta/interfaces','qta/interfaces/tools',...
  'qta/interfacesEBSD','qta/interfacesEBSD/tools',...
  'qta/standardODFs','qta/tools',...
  'geometry','geometry/geometry_tools',...
  'tools','tools/dubna_tools','tools/file_tools','tools/option_tools',...
  'tools/import_wizard','tools/plot_tools','tools/statistic_tools',...
  'tools/misc_tools','tools/math_tools',...
  'examples','tests',...
  'help/interfaces','help/ODFAnalysis','help/PoleFigureAnalysis','help/EBSDAnalysis','help/plotting'};

for i = 1:length(toadd)
  p = [local_path,filesep,toadd{i}];
  addpath(p,0);
end


%% set path to MTEX directories
set_mtex_option('mtex_path',local_path);
set_mtex_option('mtex_data_path',[local_path filesep 'data']);
set_mtex_option('mtex_startup_dir',pwd);
set_mtex_option('architecture',computer('arch'));


%% init settings
mtex_settings;


%% check installation
check_installation;

%% finish
disp('MTEX toolbox (v1.1) loaded')
disp(' ');
if isempty(javachk('desktop'))
  disp('Basic tasks:')
  disp('- <a href="matlab:doc mtex">Show MTEX documentation</a>')
  disp('- <a href="matlab:import_wizard">Import pole figure data</a>')
  disp('- <a href="matlab:import_wizard(''type'',''EBSD'')">Import EBSD data</a>')
  disp(' ');
end

end
%% --------- private functions ----------------------


%% mtext installation
function install_mtex(local_path)

% check wether local_path is in search path
if ispc
  cellpath = splitstr(path,';'); 
else
  cellpath = splitstr(path,':'); 
end

if any(strcmpi(local_path,cellpath)), return;end


% if not yet installed
disp(' ');
disp('MTEX is currently not installed.');
disp('--------------------------------')

% look for older version
if any(strfind(path,'mtex'))
  disp('I found an older version of MTEX!');
  disp('I remove it from the current search path!');
  for i = 1:length(cellpath)
    if strfind(cellpath{i},'mtex')
      rmpath(cellpath{i});
    end
  end  
end


cd('..'); % leave current directory for some unknown reason
addpath(local_path);

disp(' ');
r= input('Do you want to permanently install MTEX? Y/N [Y]','s');
if isempty(r) || any(strcmpi(r,{'Y',''}))

  % check for old startup.m
  if exist([toolboxdir('local'),'/startup.m'],'file')
    disp(['> There is an old file startup.m in ' toolboxdir('local')]);
    disp('> I''m going to remove it!');
    if ispc
      delete([toolboxdir('local'),'/startup.m']);
    else
      sudo(['rm ' toolboxdir('local'),'/startup.m'])
    end
  end
  
  disp(' ');
  disp('> Adding MTEX to the MATLAB search path.');
  if isunix || ismac
    install_mtex_linux;
  else
    install_mtex_windows;
  end
  
end
  

disp(' ');
disp('MTEX is now running. However MTEX documentation might not be functional.');
disp('In order to see the documentation restart MATLAB or click');
disp('start->Desktop Tools->View Source Files->Refresh Start Button');
disp('-----------------------------------------------------------------');
disp(' ');
if isempty(javachk('jvm'))
  doc; pause(0.1);commandwindow;
end


end

%% windows
function install_mtex_windows
  
if ~savepath
  disp('> MTEX permanently added to MATLAB search path.');
else
  disp(' ');
  disp('> Warning: The MATLAB search path could not be saved!');
  disp('> Save the search path manually using the MATLAB menu File -> Set Path.');
end

end

%% Linux
function out = install_mtex_linux

if ~savepath % try to save the normal way
  disp('> MTEX permanently added to MATLAB search path.');
else
  
  % if it fails save to tmp dir and move
  savepath([tempdir 'pathdef.m']);

  % move pathdef.m
  out = sudo(['mv ' tempdir '/pathdef.m ' toolboxdir('local')]);

  if ~out
    disp(' ');
    disp('> Warning: The MATLAB search path could not be saved!');
    disp('> In order to complete the installation you have to move the file');
    disp(['   ' tempdir '/pathdef.m']);
    disp('    to');
    disp(['   ' toolboxdir('local')]);
  else
    disp('> MTEX permanently added to MATLAB search path.');
  end
end

end

function out = sudo(c)

disp('> I need root privelegs to perform the following command');
disp(['>   ' c]);
disp('> Please enter the password!');

% is there sudo?
if exist('/usr/bin/sudo','file') 
  
  out = ~system(['sudo ' c]);
  
else % use su
  
  out = ~system(['su -c ' c]);
  
end

end

%%
function cstr = splitstr(str,c)

pos = [0,findstr(str,c),length(str)+1];
cstr = arrayfun(@(i) str(pos(i-1)+1:pos(i)-1),2:length(pos),'uniformoutput',0);
end
