function varargout = subsref(S2G,s)
%overloads subsref

switch s(1).type
  case '()'

    v = vector3d(S2G);
    [varargout{1:nargout}] = subsref(v,s);
      
  case '.'

    [varargout{1:nargout}] = builtin('subsref',S2G,s);
    
end
end
