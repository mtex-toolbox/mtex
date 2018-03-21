function varargout = subsref(dS,s)
%overloads subsref

switch s(1).type
  case '()'
    
    dS.b = subsref(dS.b,s(1));
    dS.l = subsref(dS.l,s(1));
    dS.u = subsref(dS.u,s(1));
      
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',dS,s(2:end));
    else
      varargout{1} = dS;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',dS,s);
      
end
end
