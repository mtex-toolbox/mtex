function obj = set(obj,vname,value)
% set object variable to value

for i = 1:numel(obj)
  obj(i).(vname) = value;
end
