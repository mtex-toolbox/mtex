function value = get(obj,vname,varargin)
% get object variable

switch vname
  case {'CS','SS','comment','options'}
    value = obj(1).(vname);
  case fields(obj)
    value = obj(1).(vname);
  case 'resolution'
    try
      k = [obj.psi];
      hw = get(k,'halfwidth');
      value = min(hw);
    catch %#ok<CTCH>
      value = 5*degree;
    end
  otherwise
    error('Unknown field in class ODF!')
end

