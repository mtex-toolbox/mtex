function varargout = subsref(sS,s)
%overloads subsref

switch s(1).type
  case '()'
    
    sS.b = subsref(sS.b,s(1));
    sS.n = subsref(sS.n,s(1));
    
    sS.b = sS.b(:);
    sS.n = sS.n(:);
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',sS,s(2:end));
    else
      varargout{1} = sS;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',sS,s);
      
end
end
