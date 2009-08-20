function obj = set(obj,vname,value)
% set object variable to value


if any(strcmpi(vname,fields(obj)))
  vname = lower(vname);
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
  vname2 = fields(obj(1).properties);
  exists = strcmpi(vname,vname2); %case sensitiv
  if any(exists),  vname = vname2{exists}; end

  if iscell(value);
    for k=1:numel(obj)
      obj(k).properties.(vname) = value{k};
    end
  else
    for k=1:numel(obj)
      obj(k).properties.(vname) = value(k);
    end
  end
end

