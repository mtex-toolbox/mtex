function [data,interface,options,idata] = loadData(fname,type,varargin)
% import PoleFigure, EBSD, and ODF data
%
% Description
% *loadData* is a low level method for importing EBSD, PoleFigure, ODF and
% Tensor data from external files. It autodetects the format of the file.
% As parameters the method requires a filename and the crystal and specimen
% @symmetry. 
%
% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
% Output
%  data - @EBSD, @PoleFigure, @ODF, @tensor, @vector3d, @orientation
%
% See also
% ImportEBSDData EBSD/calcODF ebsd_demo loadEBSD_generic

% process input arguments

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
posCS = find(cellfun(@(x) checkClass(x,'symmetry'),varargin),2);

sym = {};
if ~isempty(posCS)
  cs = varargin{posCS(1)};
  if strcmpi(type,'ODF')
    sym = {'cs',cs};
    clear cs;
  end
  
end

if numel(posCS) ==2
  ss = varargin{posCS(2)};
  if strcmpi(type,'ODF')
    sym = [sym,'ss',{ss}];
    clear ss;
  end
end

varargin(posCS) = [];

% ---------- determine interface ---------------------------

if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname{1},type,varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
end

if isempty(interface), return; end

% --------------- import data ---------------------------------

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
    [~,fn,ext] = fileparts(fname{k});
    waitbar(k/numel(fname),hw,['Loading data file ',[fn ext]]);
  end
  
  data{k} = feval(['load' type '_',char(interface)],...
    fname{k},options{:},sym{:},'InfoLevel',InfoLevel);  
end
if exist('hw','var'), close(hw);end

idata = cellfun('prodofsize',data);

% ------------- apply options ----------------------------------

% set file name
for i = 1:numel(data)
  data{i} = data{i}.setOption('file_name',ls(fname{i}));
end

if strcmpi(type,'EBSD') && check_option(varargin,'3d')
  Z = get_option(varargin,'3d',1:numel(data),'double');
  for k=1:numel(data)
    data{k}.z = repmat(Z(k),length(data{k}),1);
  end
  data = [data{:}];
  data.unitCell = calcUnitCell([data.x(:),data.y(:),data.z(:)],varargin{:});
end

% set crystal and specimen symmetry, specimen direction
if ~any(strcmpi(type,{'tensor','vector3d'}))
  if iscell(data)
    data = cellfun(@(d,f) setOption(d,'file_name',strtrim(ls(f))),data,fname,'UniformOutput',false);
    data = [data{:}];
  end
    
  if exist('cs','var'), data.CS = cs;end
  if exist('ss','var') && ~isa(data,'EBSD'), data.SS = ss;end % TODO
  if exist('h','var'),  data = set(data,'h',h);end
  if ~isempty_cell(c),  data = set(data,'c',c);end
else
  data = [data{:}];
  
  if exist('cs','var')
    if iscell(data)
      for i = 1:numel(data), data{i}.CS = cs; end
    else
      data.CS = cs;
    end
    if exist('ss','var')
      if iscell(data)
        for i = 1:numel(data), data{i}.SS = ss; end
      else
        data.SS = ss;
      end
    end
  end
  
end

% rotate data
if check_option(varargin,'rotate')
  data = rotate(data,axis2quat(zvector,get_option(varargin,'rotate')));
end

% --------------------------------------------------------------
function v = checkClass(var,className)

if iscell(var) && ~isempty(var)
  v = any(cellfun('isclass',var,className));
else
  v = isa(var,className);
end









