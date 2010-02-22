function varargout = get(obj,vname,varargin)
% get object variable

switch vname
  case {'CS','SS','comment','options'}
    varargout{1} = obj(1).(vname);
    
  case 'symmetry'
    varargout{1} = obj(1).CS;
    varargout{2} = obj(1).SS;
    
  case 'weights'
    
    for i=1:length(obj)
      w(i) = sum(obj(i).c(:)); %#ok<AGROW>
    end
    varargout{1} = w;
    
  case fields(obj)
    varargout{1} = obj(1).(vname);
    
  case 'resolution'
    try
      k = [obj.psi];
      hw = get(k,'halfwidth');
      varargout{1} = min(hw);
    catch %#ok<CTCH>
      varargout{1} = 5*degree;
    end
  otherwise
    error('Unknown field in class ODF!')
end

