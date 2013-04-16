function varargout = subsref(r,s)
% overloads subsref

if isa(s,'double') || isa(s,'logical')
  
  r.a = r.a(s);
  r.b = r.b(s);
  r.c = r.c(s);
  r.d = r.d(s);
  r.i = r.i(s);
  varargout{1} = r;
  
elseif isstruct(s)
  
  switch s(1).type
    case '()'      
      r.a = subsref(r.a,s);
      r.b = subsref(r.b,s);
      r.c = subsref(r.c,s);
      r.d = subsref(r.d,s);
      r.i = subsref(r.i,s);
      varargout{1} = r;
    case '.'
      [varargout{1:nargout}] = builtin('subsref',r,s);
  end
  
end

end