function varargout = subsref(S2F, s)
% overloads subsref

switch s(1).type
  case '()'
    
    if (size(S2F.nodes, 1) == 1 || size(S2F.nodes, 2) == 1)
      s(1).subs = [':', s(1).subs];
    else
      s(1).subs = [repmat({':'}, 1, ndims(S2F.nodes)), s(1).subs];
    end
     S2F.values = subsref(S2F.values, s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref', S2F, s(2:end));
    else
      varargout{1} = S2F;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref', S2F, s);
      
end
end
