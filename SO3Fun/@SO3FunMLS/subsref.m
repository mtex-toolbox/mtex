function varargout = subsref(SO3F,s)
% overloads subsref

switch s(1).type
  case '()'
    
    if (size(SO3F.nodes, 1) == 1 || size(SO3F.nodes, 2) == 1)
      s(1).subs = [':', s(1).subs];
    else
      s(1).subs = [repmat({':'}, 1, ndims(SO3F.nodes)), s(1).subs];
    end
    SO3F.values = subsref(SO3F.values, s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',SO3F,s(2:end));
    else
      varargout{1} = SO3F;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref',SO3F,s);
      
end
end
