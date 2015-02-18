function [d,options,header,c] = load_generic(fname,varargin)
% load file using import data and txt2mat

if ~exist(fname,'file'), error(['File ' fname ' not found!']); end

% get options
if check_option(varargin,'header')
  options{1} = get_option(varargin,'header');
else
  options = {};  
end    

minColumns = get_option(varargin,'minColumns',3);

c = extract_option(varargin,'ReplaceExpr','cell');
InfoLevel = get_option(varargin,'InfoLevel',1);
options = [options,c];

d = [];

if ~check_option(varargin,'noascii')
  
  % replace delimiters
  if strcmpi(fname(end-2:end),'csv')
    rc = {'\t, '};
  else
    rc = {'\t ',',.'};
  end
  
  %if check_option(varargin,'Columns')
  %  options =  [options,{'NumColumns',max(get_option(varargin,'Columns'))}];
  %end
  % read data using txt2mat
  try
    if check_option(varargin,'check')
      [d,ffn,nh,SR,header] = txt2mat(fname,options{:},...
        'RowRange',[1 1000],'InfoLevel',0,'ReplaceChar',rc);
    else
      [d,ffn,nh,SR,header] = txt2mat(fname,options{:},'InfoLevel',InfoLevel,'ReplaceChar',rc);
    end
  catch %#ok<CTCH>
  end
  
  % data found?
  if size(d,1)>0 && size(d,2)>=minColumns,
    c = extract_colnames(header,size(d,2));
    options = delete_option(varargin,'check');
    return;
  end
end

% read data using importdata
try
  
  if check_option(varargin,'delimiter')
    options{1} = get_option(varargin,'delimiter',' ');
  end
  
  if check_option(varargin,'header')
    options{2} = get_option(varargin,'header',0);  
  end  
  
  d = importdata(fname,options{:});
      
catch %#ok<CTCH>
end

[d,c,header] = extract_data(d);

% data found?
if ~isempty(d)    
  options = [varargin,{'noascii'}];
  return
end



function c = extract_colnames(header,ncol)

c = [];
try
  % split into rows
  rows = regexpsplit(header,'\n');
  %find last not empty row
  while iscell(rows)
    if isempty(rows{end}) || isempty(regexp(rows{end},'\w'))
      rows = {rows{1:end-1}};
    else
      rows = rows{end};
    end
  end
   
  % extract colum header
  
  c = regexpsplit(rows,'[,;:]');
  c = {c{~cellfun(@isempty,c)}}; % löscht evt. leere zellen.
  if length(c) == ncol, return;end
  
  % try regular
  c = regexpsplit(rows,'\s+');
  c = {c{~cellfun(@isempty,c)}}; % löscht evt. leere zellen.
  if length(c) == ncol, return;end
  
  
  % try fancy
  c = regexpsplit(rows,'\s\s+');
  c = {c{~cellfun(@isempty,c)}}; % löscht evt. leere zellen.
  
catch %#ok<CTCH>
end

function [d,c,header] = extract_data(s)

c = []; d = [];header=[];
if isfield(s,'colheaders'), c = s.colheaders;end
if isfield(s,'textdata'), header = s.textdata;end
  
if isstruct(s)
  
  fn = fieldnames(s);
  i = 1;
  while i <= length(fn) && isempty(d)
    d = extract_data(s.(fn{i}));
    i = i+1;
  end
  
elseif iscell(s) && ischar(s)
  
  i = 1;
  while i <= length(s) && isempty(d)
    d = extract_data(s{i});
    i = i+1;
  end
  
elseif isnumeric(s) && size(s,1)>10 && size(s,2)>2
  d = s;
end
