function varargout = subsref(sS,s)
%overloads subsref

switch s(1).type
  case '()'
    
    sS.b = subsref(sS.b,s(1));
    sS.n = subsref(sS.n,s(1));
    sS.CRSS = subsref(sS.CRSS,s(1));
      
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',sS,s(2:end));
    else
      varargout{1} = sS;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',sS,s);
      
end
end
