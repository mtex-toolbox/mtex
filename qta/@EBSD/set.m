function obj = set(obj,vname,value,varargin)
% set object variable to value


if any(strcmp(vname,fields(obj)))
  for i = 1:numel(obj)

    % is value is a cell spread it over all elements of obj
    if iscell(value) && length(value) == length(obj)
      ivalue = value{i};
    elseif iscell(value)
      ivalue = value{1};
    else
      ivalue = value;
    end

    obj(i).(vname) = ivalue;
    if strcmp(vname,'CS'), obj(i).orientations = set(obj(i).orientations,'CS',{ivalue},varargin{:});end
    if strcmp(vname,'SS'), obj(i).orientations = set(obj(i).orientations,'SS',{ivalue},varargin{:});end
  end
else
  for k=1:numel(obj)
    if iscell(value)
      ivalue = value{k};
    else
      ivalue = value;
    end
    obj(k).options.(vname) = ivalue;  
  end
end

