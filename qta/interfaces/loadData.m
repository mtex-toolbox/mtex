function [data,interface,options,idata] = loadData(fname,type,varargin)
% import PoleFigure, EBSD, and ODF data 
%
%% Description
% *loadEBSD* is a high level method for importing EBSD data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% [[loadEBSD_generic.html,loadEBSD_generic]] for additional options.
%
%% Syntax
%  pf = loadEBSD(fname,cs,ss,<options>)
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
  fname = strcat([pname filesep],{files.name});
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

data = []; idata = ones(1,length(fname));
if isempty(interface), return; end

%% import data

% determine superposition - PoleFigure only
c = get_option(options,'superposition');
if isa(c,'double'), c = {c};end

for i = 1:length(fname)  
  newdata = feval(['load' type '_',char(interface)],fname{i},options{:},sym{:});
  data = [data,newdata]; %#ok<AGROW>
  idata(i) = length(newdata);
end


if strcmpi(type,'EBSD') && check_option(varargin,'3d')
  Z = get_option(varargin,'3d',[],'double');
  
  if isempty(Z), warning('Z-Values for each data layer are not specified!');
    Z = 1:numel(idata); end
  csz = [0 cumsum(idata)];
  
  for k=1:numel(idata)
    ndx = csz(k)+1:csz(k+1);
    for l=1:numel(ndx)
      xy = get(data(ndx(l)),'X');
      xy(:,3) = Z(k);
      data(ndx(l)) = set(data(ndx(l)),'X',xy);
    end    
  end
  data = union(data);  %#ok<LTARG>
end


%% set crystal and specimen symmetry

if exist('cs','var'), data = set(data,'CS',cs,'noTrafo');end
if exist('ss','var'), data = set(data,'SS',ss,'noTrafo');end
if exist('h','var'),  data = set(data,'h',h);end
if ~isempty_cell(c),  data = set(data,'c',c);end

%% set comment

pos = cumsum([0,idata]);
[ps,fn,ext] = fileparts([fname{find(i>pos,1,'last')}]);

if strcmpi(type,'Tensor') % subsasgn, subsref
  data = set(data,'comment',...
     get_option(varargin,'comment',[fn ext]));  
  data = set(data,'name',get_option(varargin,'name',''));
  data = set(data,'units',get_option(varargin,'units',''));
else  
  for i = 1:length(data)
    data(i) = set(data(i),'comment',...
      get_option(varargin,'comment',[fn ext])); %#ok<AGROW>
  end
end

%% rotate data
if check_option(varargin,'rotate')
  data = rotate(data,axis2quat(zvector,get_option(varargin,'rotate')));
end

function v = checkClass(var,className)

if iscell(var) && ~isempty(var), var = var{1};end
v = isa(var,className);
