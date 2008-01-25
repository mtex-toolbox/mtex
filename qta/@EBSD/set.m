function nobj = set(obj,vname,value)
% set object variable to value

for i = 1:numel(obj)
  obj(i).(vname) = value;
  if strcmp(vname,'CS'), obj(i).orientations = set(obj(i).orientations,'CS',{value});end
  if strcmp(vname,'SS'), obj(i).orientations = set(obj(i).orientations,'SS',{value});end
end

nobj = obj;
