function startup_mtex(varargin)
% init MTEX session
%
% This is the startup file for MTEX. In general it is not necessary to edit
% this file. The startup options of MTEX can be edited in the file
% mtex_settings.m in this directory.
%


%% Check MATLAB version

lasterr('') %#ok<LERR> %reset all errors

if (~isOctave() && MATLABverLessThan('7.11'))

  error(['MTEX can not be installed because your MATLAB version ',version,...
    ' is outdated and not longer supported by MTEX. The oldest MATLAB ',...
    'version MTEX has been tested on is 7.11.']);
end


%%
% path to this function to be considered as the root of the MTEX
% installation
local_path = fileparts(mfilename('fullpath'));


%% needs installation ?

do_install(local_path);

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

setMTEXpref('mtexPath',local_path);
setMTEXpref('DataPath',fullfile(local_path,'data'));
setMTEXpref('architecture',computer('arch'));
setMTEXpref('version',MTEXversion);
setMTEXpref('generatingHelpMode',false);
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
else
  disp(' done!')
end



if ~isOctave() && isempty(javachk('desktop')) && ~check_option(varargin,'noMenu')
  MTEXmenu;
end


end
%% --------- private functions ----------------------


%% mtex installation
function do_install(local_path)

% check wether local_path is in search path
cellpath = regexp(path,['(.*?)\' pathsep],'tokens');
cellpath = [cellpath{:}]; %cellpath = regexp(path, pathsep,'split');
if isappdata(0,'mtex'), rmappdata(0,'mtex'); end
if any(strcmpi(local_path,cellpath))
  setappdata(0,'MTEXInstalled',true);
  if ispref('mtex'), rmpref('mtex');end % remove old settings
  return;
else
  setappdata(0,'MTEXInstalled',false);
end



% look for older version
if any(strfind(path,'mtex'))
  disp('I found an older version of MTEX and remove it from the current search path!');

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

end

%% set MTEX search path
function setMTEXPath(local_path)

% obligatory paths
pathes = { {''}, ...
  {'qta'}, {'qta' 'interfaces'},{'qta' 'interfaces' 'tools'},...
  {'qta' 'standardODFs'},{'qta' 'tools'},...
  {'geometry'},{'geometry' 'geometry_tools'},...
  {'tools'},{'tools' 'orientationMappings'},{'tools' 'dubna_tools'},...
  {'tools' 'file_tools'},{'tools' 'option_tools'},...
  {'tools' 'import_wizard'},{'tools' 'plot_tools'},{'tools' 'statistic_tools'},...
  {'tools' 'misc_tools'},{'tools' 'math_tools'},{'tools' 'graph_tools'},{'tools' 'compatibility'},...
  {'tools' 'template_wizard'},{'tools','colormaps'},...
  {'help','doc','FunctionReference','classes'},...
  {'examples'},{'examples' 'UsersGuide'},...
  {'tests'},{'extern','export_fig'},{'extern'}};

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

function result = isOctave ()
  persistent is_octave;
  is_octave = exist ('OCTAVE_VERSION');
  result = is_octave;
end
