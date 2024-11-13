function varargout = subsref(plane,s)
%overloads subsref

switch s(1).type
  case '()'
    
    plane.N = subsref(plane.N,s(1));
    plane.d = subsref(plane.d,s(1));

    plane.opt = struct;
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',plane,s(2:end));
    else
      varargout{1} = plane;
    end  
  otherwise
    
    [varargout{1:nargout}] = builtin('subsref',plane,s);
      
end
end
