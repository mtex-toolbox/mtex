function varargout = subsref(sym,s)
% overloads subsref

switch s(1).type
  case '()'

    % subindexing symmetry is rotation!!
    [varargout{1:nargout}] = subsref@rotation(rotation(sym),s);
      
  case '.'

    [varargout{1:nargout}] = builtin('subsref',sym,s);
    
end
