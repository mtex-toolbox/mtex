function varargout = subsref(v,s)
%overloads subsref

switch s(1).type
  case '()'
    
    v.x = subsref(v.x,s(1));
    v.y = subsref(v.y,s(1));
    v.z = subsref(v.z,s(1));
    
    try v.opt = rmfield(v.opt,'resolution'); end %#ok<TRYNC>
    try v.opt = rmfield(v.opt,'region'); end %#ok<TRYNC>
    try v.opt = rmfield(v.opt,{'theta','rho','plot'}); end %#ok<TRYNC>
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',v,s(2:end));
    else
      varargout{1} = v;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',v,s);
      
end
end
