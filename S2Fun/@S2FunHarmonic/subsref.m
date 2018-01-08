function varargout = subsref(sF,s)
% overloads subsref

switch s(1).type
  case '()'
    
    s(1).subs = [':' s(1).subs];
    sF.fhat = subsref(sF.fhat,s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',sF,s(2:end));
    else
      varargout{1} = sF;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref',sF,s);
      
end
end
