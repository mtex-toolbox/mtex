function varargout = subsref(r,s)
% overloads subsref
 
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
    [varargout{1:nargout}] = subsref@dynOption(r,s);
end
  
end
