function varargout = subsref(q,s)
% overloads subsref

if isa(s,'double') || isa(s,'logical')

  q.a = q.a(s);
  q.b = q.b(s);
  q.c = q.c(s);
  q.d = q.d(s);
  varargout{1} = q;
  
elseif isstruct(s)
  switch s(1).type
    case '()'
  
      q.a = subsref(q.a,s);
      q.b = subsref(q.b,s);
      q.c = subsref(q.c,s);
      q.d = subsref(q.d,s);
      varargout{1} = q;
      
    case '.'
      [varargout{1:nargout}] = builtin('subsref',q,s);
  end
end

end