function varargout = subsref(q,s)
% overloads subsref
  
switch s(1).type
  case '()'
  
    q.a = subsref(q.a,s(1));
    q.b = subsref(q.b,s(1));
    q.c = subsref(q.c,s(1));
    q.d = subsref(q.d,s(1));
            
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',q,s(2:end));
    else
      varargout{1} = q;
    end
      
  otherwise
    [varargout{1:nargout}] = builtin('subsref',q,s);
end
end
