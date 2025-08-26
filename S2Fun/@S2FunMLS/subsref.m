function varargout = subsref(S2F,s)
% overloads subsref

switch s(1).type
  case '()'
    
    s(1).subs = [':' s(1).subs];
    S2F.values = subsref(S2F.values,s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',S2F,s(2:end));
    else
      varargout{1} = S2F;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref',S2F,s); 
      
end
end