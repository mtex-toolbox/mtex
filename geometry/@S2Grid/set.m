function obj = set(obj,vname,value)
% set object variable

for i = 1:length(obj)
  switch vname
    case fields(obj)
      obj(i).(vname) = value;
    otherwise
      error('Unknown field in class S2Grid!')
  end
end
