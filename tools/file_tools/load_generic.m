function [d,options,header] = load_generic(fname,varargin)
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

d = extract_data(d);

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

function d = extract_data(s)

d = [];
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
