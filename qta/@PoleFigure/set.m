function obj = set(obj,vname,value)
% set object variable to value

for i = 1:numel(obj)
  
  % is value is a cell spread it over all elements of obj
  if iscell(value)
    ivalue = value{i};
  else
    ivalue = value;
  end
  
  obj(i).(vname) = ivalue;
  if strcmp(vname,'CS'), obj(i).h = set(obj(i).h,'CS',ivalue);end
  
end

