function startup_mtex
% init MTEX session
%
% This is the startup file for MTEX. In general it is not necessary to edit
% this file. The startup options of MTEX can be edited in the file
% mtex_settings.m in this directory.
%

%% start MTEX
disp('initialize MTEX ...');

% path to this function to be considered as the root of the MTEX
% installation 
local_path = fileparts(mfilename('fullpath'));


%% needs installation ?

install_mtex(local_path);

%% setup search path 

setMTEXPath(local_path);

%% set path to MTEX directories

set_mtex_option('mtex_path',local_path);
set_mtex_option('mtex_data_path',fullfile(local_path,'data'));
set_mtex_option('mtex_startup_dir',pwd);
set_mtex_option('architecture',computer('arch'));

%read version from version file
fid = fopen('VERSION','r');
ver = fread(fid,'*char')';
fclose(fid);
set_mtex_option(0,'version',ver(1:end-1));


%% init settings
mtex_settings;


%% check installation
check_installation;

%% finish
disp([get_mtex_option('version') ' toolbox loaded'])
disp(' ');
if isempty(javachk('desktop'))
  disp('Basic tasks:')
  disp('- <a href="matlab:doc mtex">Show MTEX documentation</a>')
  disp('- <a href="matlab:import_wizard">Import pole figure data</a>')
  disp('- <a href="matlab:import_wizard(''type'',''EBSD'')">Import EBSD data</a>')
  disp('- <a href="matlab:import_wizard(''type'',''ODF'')">Import ODF data</a>')
  disp(' ');
end

end
%% --------- private functions ----------------------


%% mtext installation
function install_mtex(local_path)

% check wether local_path is in search path
cellpath = regexp(path,['(.*?)\' pathsep],'tokens'); 
cellpath = [cellpath{:}]; %cellpath = regexp(path, pathsep,'split');
if any(strcmpi(local_path,cellpath)), return;end

% if not yet installed
disp(' ');
disp('MTEX is currently not installed.');
disp('--------------------------------')

% look for older version
if any(strfind(path,'mtex'))
  disp('I found an older version of MTEX!');
  disp('I remove it from the current search path!');
  
  inst_dir = cellpath(~cellfun('isempty',strfind(cellpath,'mtex')));  
  if ~isempty(inst_dir), rmpath(inst_dir{:}); end
  clear classes
end


cd('..'); % leave current directory for some unknown reason
addpath(local_path);

disp(' ');
r= input('Do you want to permanently install MTEX? Y/N [Y]','s');
if isempty(r) || any(strcmpi(r,{'Y',''}))

  % check for old startup.m
  startup_file = fullfile(toolboxdir('local'),'startup.m');
  if exist(startup_file,'file')
    disp(['> There is an old file startup.m in ' toolboxdir('local')]);
    disp('> I''m going to remove it!');
    if ispc
      delete(startup_file);
    else
      sudo(['rm ' startup_file])
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


%% sudo for linux
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

%% set MTEX search path
function setMTEXPath(local_path)

% obligatory paths
toadd = { {''}, ...
  {'qta'}, {'qta' 'interfaces'},{'qta' 'interfaces' 'tools'},...
  {'qta' 'standardODFs'},{'qta' 'tools'},...
  {'geometry'},{'geometry' 'geometry_tools'},...
  {'tools'},{'tools' 'dubna_tools'}, {'tools' 'file_tools'},{'tools' 'option_tools'},...
  {'tools' 'import_wizard'},{'tools' 'plot_tools'},{'tools' 'statistic_tools'},...
  {'tools' 'misc_tools'},{'tools' 'math_tools'},{'tools' 'compatibility'},...
  {'examples'},{'tests'},...
  {'help' 'interfaces'},{'help' 'ODFAnalysis'},{'help' 'PoleFigureAnalysis'},...
  {'help' 'EBSDAnalysis'},{'help' 'plotting'},{'help' 'CrystalGeometry'}};

for k=1:length(toadd)
  addpath(fullfile(local_path,toadd{k}{:}),0);
end

% compatibility path
comp = dir(fullfile(local_path,'tools','compatibility','ver*'));

for k=1:length(comp)
  if MATLABverLessThan(comp(k).name(4:end))
    addpath(genpath(fullfile(local_path,'tools','compatibility',comp(k).name)),0);
  end
end

if MATLABverLessThan('7.3'), make_bsx_mex;end

end

%% check MATLAB version 
function result = MATLABverLessThan(verstr)

MATLABver = ver('MATLAB');

toolboxParts = getParts(MATLABver(1).Version);
verParts = getParts(verstr);

result = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;

end

function parts = getParts(V)
parts = sscanf(V, '%d.%d.%d')';
if length(parts) < 3
  parts(3) = 0; % zero-fills to 3 elements
end
end
