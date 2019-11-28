function varargout = subsref(F,s)
% overloads subsref

switch s(1).type
  case '()'
    
    s(1).subs = [':' s(1).subs];
    F.fhat = subsref(F.fhat,s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',F,s(2:end));
    else
      varargout{1} = F;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref',F,s);
      
end
end
