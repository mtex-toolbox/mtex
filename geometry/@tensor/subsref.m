function varargout = subsref(T,s)
%overloads subsref

if strcmp(s(1).type,'()')

  s.subs = [repcell(':',1,T.rank) s.subs];
    
  T.M = subsref(T.M,s);
      
  if numel(s)==1
    varargout{1} = T;
    return;
  else
    s = s(2:end);
  end
end
  
try
  [varargout{1:nargout}] = builtin('subsref',T,s);
catch
  [varargout{1:nargout}] = subsref@dynOption(T,s);
end
