function varargout = subsref(q1,s)
% overloads subsref

varargout = cell(1,nargout);
if isa(s,'double')
	varargout{1} = quaternion(q1.a(s),q1.b(s),q1.c(s),q1.d(s));
else
  ss = s(1);
  switch ss.type
    case '()'
      q1 = quaternion(subsref(q1.a,ss),subsref(q1.b,ss),subsref(q1.c,ss),subsref(q1.d,ss));
    case '.'
      q1 = q1.(ss.subs);
    otherwise
      error('wrong data type');
  end
  if length(s) > 1
    varargout{1} = subsref(q1,s(2:end));
  else
    varargout{1} = q1;
  end
end

