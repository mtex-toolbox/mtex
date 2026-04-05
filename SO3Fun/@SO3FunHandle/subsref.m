function varargout = subsref(SO3F,s)
% overloads subsref

switch s(1).type
  case '()'
    
    s(1).subs = [':' s(1).subs];
    SO3F.fun = @(r) subsref(SO3F.eval(r),s(1));
    
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',SO3F,s(2:end));
    else
      varargout{1} = SO3F;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref',SO3F,s);
      
end
end
