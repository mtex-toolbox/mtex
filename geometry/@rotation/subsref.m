function varargout = subsref(r,s)
% overloads subsref

if ~isstruct(s)
  
  r.a = r.a(s);
  r.b = r.b(s);
  r.c = r.c(s);
  r.d = r.d(s);
  r.i = r.i(s);
  varargout{1} = r;
  
else
  
  switch s(1).type
    case '()'      
      r.a = subsref(r.a,s(1));
      r.b = subsref(r.b,s(1));
      r.c = subsref(r.c,s(1));
      r.d = subsref(r.d,s(1));
      r.i = subsref(r.i,s(1));
      
      if numel(s)>1
        [varargout{1:nargout}] = builtin('subsref',r,s(2:end));
      else
        varargout{1} = r;
      end
      
    case '.'
      [varargout{1:nargout}] = builtin('subsref',r,s);
  end
  
end

end
