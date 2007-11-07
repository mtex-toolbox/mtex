function varargout = subsref(v1,s)
%overloads subsref

varargout = cell(1,nargout);
if isa(s,'double')
	varargout{1} = vector3d(v1.x(s),v1.y(s),v1.z(s));
else
  ss = s(1);
  switch ss.type
    case '()'
      v1 = vector3d(subsref(v1.x,ss),subsref(v1.y,ss),...
        subsref(v1.z,ss));
    case '.'
      v1 = [v1.(ss.subs)];
    otherwise
      error('wrong data type');
  end
  if length(s) > 1
    varargout{1} = subsref(v1,s(2:end));
  else
    varargout{1} = v1;
  end
end
