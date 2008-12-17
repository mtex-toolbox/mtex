function [d,options,header,c] = load_generic(fname,varargin)
% load file using import data and txt2mat

% get options
if check_option(varargin,'header')
  options{1} = get_option(varargin,'delimiter',' ');  
  options{2} = get_option(varargin,'header');   
else
  options = {};  
end    

d = [];

if ~check_option(varargin,'noascii')
  % read data using txt2mat
  try
    if check_option(varargin,'check')
      [d,ffn,nh,SR,header] = txt2mat(fname,options{2:end},...
        'RowRange',[1 1000],'InfoLevel',0);
    else
      [d,ffn,nh,SR,header] = txt2mat(fname,options{2:end},'InfoLevel',0);
    end
  catch %#ok<CTCH>
  end
  
  % data found?
  if size(d,1)>10 && size(d,2)>2,
    c = extract_colnames(header);
    options = delete_option(varargin,'check');
    return;
  end
end

% read data using importdata
try
  d = importdata(fname,options{:});
catch %#ok<CTCH>
end

[d,c,header] = extract_data(d);

% data found?
if ~isempty(d)    
  options = {varargin{:},'noascii'};
  return
end



function c = extract_colnames(header)

c = [];
try
  % split into rows
  rows = regexp(header,'\n','split');
  %find last not empty row
  while iscell(rows)
    if isempty(rows{end})
      rows = {rows{1:end-1}};
    else
      rows = rows{end};
    end
  end
   
  % extract colum header
  c = regexp(rows,'\s','split');
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
