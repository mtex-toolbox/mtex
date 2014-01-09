function obj = set(obj,vname,value,varargin)
% set object variable to value

for i = 1:numel(obj)
  
  % is value is a cell spread it over all elements of obj
  if iscell(value)
    ivalue = value{i};
  else
    ivalue = value;
  end
  
  obj(i).(vname) = ivalue;
    
end

% TODO
%if check_option(obj(i),'fibre')
%    if strcmp(vname,'CS'), obj(i).center{1} = set(obj(i).center{1},'CS',ivalue,varargin{:});end
%  elseif isa(obj(i).center,'SO3Grid')
%    if strcmp(vname,'CS'), obj(i).center = set(obj(i).center,'CS',ivalue,varargin{:});end
%    if strcmp(vname,'SS'), obj(i).center = set(obj(i).center,'SS',ivalue,varargin{:});end
%  end

