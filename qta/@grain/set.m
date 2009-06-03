function obj = set(obj,vname,value)
% set object variable to value

vname = lower(vname);
if any(strcmp(vname,fields(obj)))
  obj.(vname) = value;
else
  for k=1:numel(obj)
    obj(k).properties.(vname) = value(k);
  end  
end

