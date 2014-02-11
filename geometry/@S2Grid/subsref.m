function varargout = subsref(S2G,s)
%overloads subsref

switch s(1).type
  case '()'

    % subindexing S2Grid is vector3d!!
    [varargout{1:nargout}] = subsref@vector3d(vector3d(S2G),s);
      
  case '.'

    [varargout{1:nargout}] = builtin('subsref',S2G,s);
    
end
end
