function obj = set(obj,phase,vname,value)
% set object variable to value

if nargin > 3
  n = phase;
else
  n = ':';
  value = vname;
  vname = phase;  
end


if any (strcmp (fields (obj),vname))
  if ~iscell(obj.(vname))
     obj.(vname) = value;
  else
    obj.(vname)(n) = value;
  end
elseif strcmp(vname,'CS'), obj.orientations(n) = set(obj.orientations(n),'CS',{value});
elseif strcmp(vname,'SS'), obj.orientations(n) = set(obj.orientations(n),'SS',{value});
else
  obj.options.(vname)(n) = {value};
end  

