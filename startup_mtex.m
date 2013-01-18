function startup_mtex(branch)
% init MTEX session
%
% This is the startup file for MTEX. In general it is not necessary to edit
% this file. The startup options of MTEX can be edited in the file
% mtex_settings.m in this directory.
%
% clc

% only switch branch
if nargin == 1

  path = getpref('mtex','mtexPath');

  cd(path);

  if strcmpi(path(end-4:end),'trunk')
    cd('..');
  else
    cd('../..');
  end

  if strcmp(branch(end-4:end),'trunk')
    cd trunk
  else
    cd(['branches' filesep branch]);
  end

  startup_mtex
  return

end

%%

lasterr('') %reset all errors

if (~isOctave() && MATLABverLessThan('7.1'))

  error(['MTEX can not be installed because your MATLAB version ',version,...
    ' is outdated and not longer supported by MTEX. The oldest MATLAB ',...
    'version MTEX has been tested on is 7.1.']);
end


%%
% path to this function to be considered as the root of the MTEX
% installation
local_path = fileparts(mfilename('fullpath'));


%% needs installation ?

install_mtex(local_path);

%% initialize MTEX
fprintf('initialize');

%read version from version file
try
  fid = fopen('VERSION','r');
  MTEXversion = fgetl(fid);
  fclose(fid);
  fprintf([' ' MTEXversion '  ']);
catch
  MTEXversion = 'MTEX';
end

p();

%% setup search path

setMTEXPath(local_path);
p();

%% set path to MTEX directories

setpref('mtex','mtexPath',local_path);
setpref('mtex','DataPath',fullfile(local_path,'data'));
setpref('mtex','architecture',computer('arch'));
setpref('mtex','version',MTEXversion);
setpref('mtex','generatingHelpMode',false);
p();


%% init settings
mtex_settings;
p();

%% check installation
check_installation;
p();

%% finish
if isempty(lasterr) % everything fine
  fprintf(repmat('\b',1,length(MTEXversion)+18));
end

disp(' done!')

if ~isOctave() && isempty(javachk('desktop'))
  MTEXmenu;
end


end
%% --------- private functions ----------------------


%% mtext installation
function install_mtex(local_path)

% check wether local_path is in search path
cellpath = regexp(path,['(.*?)\' pathsep],'tokens');
cellpath = [cellpath{:}]; %cellpath = regexp(path, pathsep,'split');
if any(strcmpi(local_path,cellpath)), return; end

if ispref('mtex'), rmpref('mtex'); end

% if not yet installed
disp(' ')
hline('-')
disp('MTEX is currently not installed.');


% look for older version
if any(strfind(path,'mtex'))
  disp('I found an older version of MTEX and remove it from the current search path!');
  disp('The documentation might not be functional.');
  
  close all
  evalin('base','clear classes')
  
  inst_dir = cellpath(~cellfun('isempty',strfind(cellpath,'mtex')));
  if ~isempty(inst_dir), rmpath(inst_dir{:}); end
  local_path = fileparts(mfilename('fullpath'));
end

if (~isOctave() && MATLABverLessThan('7.8'))
  cd('..'); % leave current directory for some unknown reason
end
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
  if ispc
    install_mtex_windows;
  else
    install_mtex_linux;
  end

end


disp(' ');
disp('MTEX is now running. However MTEX documentation might not be functional.');
disp('In order to see the documentation restart MATLAB or click');
disp('start->Desktop Tools->View Source Files->Refresh Start Button');
hline('-')
disp(' ')
if (~isOctave() && isempty(javachk('jvm')))
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
pathes = { {''}, ...
  {'qta'}, {'qta' 'interfaces'},{'qta' 'interfaces' 'tools'},...
  {'qta' 'standardODFs'},{'qta' 'tools'},...
  {'geometry'},{'geometry' 'geometry_tools'},...
  {'tools'},{'tools' 'dubna_tools'}, {'tools' 'file_tools'},{'tools' 'option_tools'},...
  {'tools' 'import_wizard'},{'tools' 'plot_tools'},{'tools' 'statistic_tools'},...
  {'tools' 'misc_tools'},{'tools' 'math_tools'},{'tools' 'graph_tools'},{'tools' 'compatibility'},...
  {'tools' 'template_wizard'},...
  {'help','doc','FunctionReference','classes'},...
  {'examples'},{'examples' 'UsersGuide'},...
  {'tests'}};

pathes = cellfun(@(p) fullfile(local_path,p{:}), pathes, 'uniformoutput', false);
addpath(pathes{:},0);

% compatibility path
if isOctave()
  addpath(genpath(fullfile(local_path,'tools','compatibility','octave')),0);
  comp = dir(fullfile(local_path,'tools','compatibility','octave','ver*'));
else
  comp = dir(fullfile(local_path,'tools','compatibility','ver*'));
end
for k=1:length(comp)
  if (isOctave() && OCTAVEverLessThan(comp(k).name(4:end))) ...
     || MATLABverLessThan(comp(k).name(4:end))
    addpath(genpath(fullfile(local_path,'tools','compatibility',comp(k).name)),0);
  end
end

if (~isOctave() && MATLABverLessThan('7.3')), make_bsx_mex;end

%addpath_recurse(fullfile(local_path,'help','UsersGuide'));

end

%% check MATLAB version
function result = MATLABverLessThan(verstr)

MATLABver = ver('MATLAB');

toolboxParts = getParts(MATLABver(1).Version);
verParts = getParts(verstr);

result = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;

end

%% check Octave version
function result = OctaveverLessThan(verstr)

toolboxParts = getParts(version ());
verParts = getParts(verstr);

result = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;

end

function parts = getParts(V)
parts = sscanf(V, '%d.%d.%d')';
if length(parts) < 3
  parts(3) = 0; % zero-fills to 3 elements
end
end

function p()
if isempty(lasterr)
  fprintf('.');
end
end


function hline(st)
if nargin < 1, st = '*'; end
disp(repmat(st,1,80));
end

function result = isOctave ()
  persistent is_octave;
  is_octave = exist ('OCTAVE_VERSION');
  result = is_octave;
end
