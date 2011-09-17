function [data,interface,options,idata] = loadData(fname,type,varargin)
% import PoleFigure, EBSD, and ODF data
%
%% Description
% *loadData* is a low level method for importing EBSD, PoleFigure, ODF and
% Tensor data from external files. It autodetects the format of the file.
% As parameters the method requires a filename and the crystal and specimen
% @symmetry. 
%
%% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
%% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
%% Output
%  ebsd - @EBSD
%
%% See also
% ImportEBSDData EBSD/calcODF ebsd_demo loadEBSD_generic

%% process input arguments

% get file names
if nargin < 1
  [fname,PathName] = uigetfile( '*.*',...
    'Select Data files');
  fname = [PathName,fname];
end

% read in directory if needed
if ischar(fname)
  if exist(fname,'dir')
    pname = fname;
  else
    pname = fileparts(fname);
  end
  files = dir(fname);
  files = files(~[files.isdir]);
  assert(~isempty(files),'No file found!');
  if ~isempty(pname) && pname(end)~=filesep, pname = [pname,filesep];end
  fname = strcat(pname,{files.name});
end

% get crystal directions
if ~isempty(varargin) && checkClass(varargin{1},'Miller')
  h = vec2cell(varargin{1});
  varargin = varargin(2:end);
end

% get crystal and specimen symmetry
sym = {};
if ~isempty(varargin) && checkClass(varargin{1},'symmetry')
  cs = varargin{1};varargin = varargin(2:end);
  if strcmpi(type,'ODF'), sym = {'cs',cs};end
end

if ~isempty(varargin) && checkClass(varargin{1},'symmetry')
  ss = varargin{1};varargin = {varargin{2:end}};
  if strcmpi(type,'ODF'), sym = [sym,'ss',{ss}];end
end

%% determine interface

if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname{1},type,varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
end

if isempty(interface), return; end

%% import data

% determine superposition - PoleFigure only
c = get_option(options,'superposition');
if isa(c,'double'), c = {c};end

if numel(fname) <= 3
  InfoLevel = 1;
else
  InfoLevel = 0;
  hw = waitbar(0,'Loading data files.');
end

for k = 1:numel(fname)
  if exist('hw','var')
    [pp,fn,ext] = fileparts(fname{k});
    waitbar(k/numel(fname),hw,['Loading data file ',[fn ext]]);
  end
  
  data{k} = feval(['load' type '_',char(interface)],...
    fname{k},options{:},sym{:},'InfoLevel',InfoLevel);  
end
if exist('hw','var'), close(hw);end

idata = cellfun('prodofsize',data);

%% apply options

if strcmpi(type,'EBSD') && check_option(varargin,'3d')
  Z = get_option(varargin,'3d',1:numel(data),'double');
  for k=1:numel(data)
    data{k} = set(data{k},'z',repmat(Z(k),numel(data{k}),1)); %#ok<AGROW>
  end
  data = [data{:}];
end



%% set crystal and specimen symmetry, specimen direction and comments
if ~strcmpi(type,'tensor')
  if iscell(data),
    data = cellfun(@(d,f) set(d,'comment',ls(f)),data,fname,'UniformOutput',false);
    data = [data{:}];
  end
  %for i = 1:length(data)
  %  data(i) = set(data(i),'comment',ls(fname{i})); %#ok<AGROW>
  %end
  
  if exist('cs','var'), data = set(data,'CS',cs,'noTrafo');end
  if exist('ss','var'), data = set(data,'SS',ss,'noTrafo');end
  if exist('h','var'),  data = set(data,'h',h);end
  if ~isempty_cell(c),  data = set(data,'c',c);end
else
  data = [data{:}];
  
  if exist('cs','var'),
    if iscell(data)
      data = cellfun(@(d) set(d,'CS',cs,'noTrafo'),data,'UniformOutput',false);
    else
      data = set(data,'CS',cs,'noTrafo');
    end
    if exist('ss','var'),
      if iscell(data)
        data = cellfun(@(d) set(d,'SS',ss,'noTrafo'),data,'UniformOutput',false);
      else
        data = set(data,'SS',ss,'noTrafo')
      end;
    end
  end
  
end

%% rotate data
if check_option(varargin,'rotate')
  data = rotate(data,axis2quat(zvector,get_option(varargin,'rotate')));
end


function v = checkClass(var,className)

if iscell(var) && ~isempty(var), var = var{1};end
v = isa(var,className);

