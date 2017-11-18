function varargout = subsref(sym,s)
% overloads subsref

switch s(1).type
  case '()'

    % subindexing symmetry is misoriatation!!
    mori = orientation(rotation(sym),sym,sym);
    [varargout{1:nargout}] = subsref(mori,s);
          
  case '.'

    [varargout{1:nargout}] = builtin('subsref',sym,s);
    
end
