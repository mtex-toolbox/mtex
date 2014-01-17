function varargout = subsref(q,s)
% overloads subsref

if isa(s,'double') || isa(s,'logical')

  q.a = q.a(s);
  q.b = q.b(s);
  q.c = q.c(s);
  q.d = q.d(s);
  varargout{1} = q;
  
else
  
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
      
    case '.'
      try
        [varargout{1:nargout}] = builtin('subsref',q,s);
      catch
        [varargout{1:nargout}] = dynProp@subsref(q,s);
      end
  end
end

end