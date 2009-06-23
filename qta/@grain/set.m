function obj = set(obj,vname,value)
% set object variable to value

vname = lower(vname);
if any(strcmp(vname,fields(obj)))
  if length(value) == length(obj)
    for k=1:numel(obj)
      obj(k).(vname) = value(k);
    end
  elseif length(value) == 1 || ischar(value)
    for k=1:numel(obj)
      obj(k).(vname) = value;
    end
  else
    error('dimension missmatch')
  end
else
  for k=1:numel(obj)
    obj(k).properties.(vname) = value(k);
  end  
end

