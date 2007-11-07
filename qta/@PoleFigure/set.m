function nobj = set(obj,vname,value)
% set object variable to value

for i = 1:numel(obj)
  obj(i).(vname) = value;
  if strcmp(vname,'CS'), obj(i).h = set(obj(i).h,'CS',value);end
end

nobj = obj;
