function startup_mtex
% init MTEX session
%
% 
%

%% set path to MTEX directories
global mtex_path;
mtex_path = fileparts(mfilename('fullpath'));

global mtex_data_path;
mtex_data_path = [mtex_path filesep 'data'];

global mtex_startup_dir;
mtex_startup_dir = pwd;


%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


%% needs installation ?
install_mtex(mtex_path);


%% setup search path 
toadd = {'',...
  'qta','qta/interfaces','qta/interfaces/tools',...
  'qta/interfacesEBSD','qta/interfacesEBSD/tools',...
  'qta/standardODFs','qta/tools',...
  'geometry','geometry/geometry_tools','geometry/minerals',...
  'tools','tools/dubna_tools','tools/file_tools','tools/option_tools',...
  'tools/import_wizard','tools/plot_tools','tools/statistic_tools',...
  'tools/misc_tools','tools/math_tools',...
  'examples','tests',...
  'help/interfaces','help/ODFCalculation','help/plotting','c/mex'};

for i = 1:length(toadd)
  p = [mtex_path,filesep,toadd{i}];
  addpath(p,0);
end

%% init settings
mtex_settings;

%% check installation
check_installation;

%% finish
disp('MTEX toolbox (v1.01) loaded')
disp(' ');
if isempty(javachk('desktop'))
  disp('Basic tasks:')
  disp('- <a href="matlab:doc mtex">Show MTEX documentation</a>')
  disp('- <a href="matlab:import_wizard">Import pole figure data</a>')
  disp('- <a href="matlab:import_wizard">Import EBSD data</a>')
  disp(' ');
end

end
%% --------- private functions ----------------------


%% mtext installation
function install_mtex(mtex_path)

% check wether mtex_path is in search path
if ispc
  cellpath = splitstr(path,';'); %regexp(path,';','split');
else
  cellpath = splitstr(path,':'); %regexp(path,':','split');
end

if any(strcmpi(mtex_path,cellpath)), return;end


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
addpath(mtex_path);

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
    r = install_mtex_linux;
  else
    r = install_mtex_windows;
  end
  
  if r, disp('> MTEX permanently added to MATLAB search path.');end
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
function out = install_mtex_windows
  
out = 0;
if ~savepath, out = 1;return;end

disp(' ');
disp('> Warning: The MATLAB search path could not be saved!');
disp('> Save the search path manually using the MATLAB menu File -> Set Path.');

end

%% Linux
function out = install_mtex_linux

% try to save the normal way
if ~savepath, out = 1;return;end

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
  
  out = ~system(['su -c mv ' tmpdir '/pathdef.m ' toolboxdir('local')]);
  
end


end

%%
function cstr = splitstr(str,c)

pos = [0,findstr(str,c),length(str)+1];
cstr = arrayfun(@(i) str(pos(i-1)+1:pos(i)-1),2:length(pos),'uniformoutput',0);
end
