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
  
if isOption(T,s(1).subs)
  if numel(s)==1
    varargout{1} = T.opt.(s(1).subs);
  else
    [varargout{1:nargout}] = subsref(T.opt.(s(1).subs),s(2:end));
  end
  %subsref@dynOption(T,s);
else
  [varargout{1:nargout}] = builtin('subsref',T,s);
end
