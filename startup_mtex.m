function startup_mtex(varargin)
% init MTEX session
%
% This is the startup file for MTEX. In general it is not necessary to edit
% this file. The startup options of MTEX can be edited in the file
% mtex_settings.m in this directory.
%

lasterr('') %#ok<LERR>

if MATLABverLessThan('8.6')
  warning(['MTEX may not be fully functional because your MATLAB version ',version,...
    ' is outdated and not longer supported by MTEX. The oldest Matlab ',...
    'version MTEX has been tested on is Matlab 2016b (vers. 8.6).']);
end
warning('off','MATLAB:contour:ConstantData')

% the folder of this file is the root of the MTEX installation
root = fileparts(mfilename('fullpath'));

if ~isdeployed, removeOldMTEX(root); end

try
  MTEXversion = strtrim(fileread(fullfile(root,'VERSION')));
catch
  MTEXversion = 'MTEX';
end

% progress line, erased again if nothing went wrong
msg = sprintf('initialize %s  ',MTEXversion);
fprintf(msg);
nDots = 0;

if ~isdeployed, setMTEXPath(root); end
dot

setMTEXpref('mtexPath',root);
setMTEXpref('DataPath',fullfile(root,'data'));
setMTEXpref('version',MTEXversion);
setMTEXpref('generatingHelpMode',false);
dot

mtex_settings;
dot

if ~isdeployed && isempty(dir(fullfile(root,'doc','html','helpsearch*')))
  disp('Creating search data base for MTEX documentation.')
  builddocsearchdb(fullfile(root,'doc','html'));
end

check_mex('fast')
dot

if isempty(lasterr)
  fprintf(repmat('\b',1,numel(msg)+nDots));
else
  disp(' done!')
end

if usejava('desktop') && ~check_option(varargin,'noMenu'), MTEXmenu; end

try set(groot,'DefaultFigureWindowStyle','normal'); end %#ok<TRYNC>

  function dot
    if isempty(lasterr), fprintf('.'); nDots = nDots + 1; end %#ok<LERR>
  end

end


function removeOldMTEX(root)
% take a previously started MTEX, this one included, off the search path

if isappdata(0,'mtex')
  old = getappdata(0,'mtex');
  rmappdata(0,'mtex');
  disp('I found another version of MTEX and remove it from the current search path!');

  close all
  w = warning('off');
  evalin('base','clear classes')
  warning(w);

  if isfield(old,'mtexPath'), rmSubPath(old.mtexPath); end
end

rmSubPath(root);
addpath(root);

end


function rmSubPath(root)
% remove root and every folder below it from the search path

p = strsplit(path,pathsep);
p = p(strncmp(p,root,numel(root)));
if ~isempty(p), rmpath(p{:}); end

end


function setMTEXPath(root)
% add all MTEX folders, skipping the compatibility folders this MATLAB does not need

skip = {'data','makeDoc','templates','nfft'};
for d = dir(fullfile(root,'compatibility','less*'))'
  if ~MATLABverLessThan(d.name(5:end)), skip{end+1} = d.name; end %#ok<AGROW>
end

folders = subFolders(root,skip);
w = warning('off','all');
addpath(folders{:});
warning(w);

end


function folders = subFolders(root,skip)
% root and recursively its subfolders, except hidden, class, package, private and skipped ones

folders = {root};
sub = dir(root);
for sub = sub([sub.isdir])'
  name = sub.name;
  if any(name(1) == '.@+') || any(strcmpi(name,[skip,{'private'}])), continue; end
  folders = [folders, subFolders(fullfile(root,name),skip)]; %#ok<AGROW>
end

end


function tf = MATLABverLessThan(v)
% ver('MATLAB') is avoided since it parses the Contents.m of every toolbox

persistent me
if isempty(me), me = parts(version); end

tf = sign(me - parts(v)) * [1; .1; .01] < 0;

end


function p = parts(v)

p = sscanf(v,'%d.%d.%d')';
p(end+1:3) = 0;

end
