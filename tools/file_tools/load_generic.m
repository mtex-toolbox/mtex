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
% read data using importdata
if ~check_option(varargin,'ascii')    
  try
    [d,del,header] = importdata(fname,options{:});
  catch
  end
end

[d,c,header] = extract_data(d);

% data found?
if ~isempty(d)    
  options = varargin;
  return
end

% read data using txt2mat
try
  [d,ffn,nh,SR,header] = txt2mat(fname,options{2:end},'InfoLevel',0);
catch
end
  
% data found?
if size(d,1)>10 || size(d,2)>2
  options = {'ascii',varargin{:}};      
end

try
  if ~isempty(header) && isempty(c)
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
    c = {c{1:end-1}};
  
  end
catch
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
