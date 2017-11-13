function varargout = subsref(bM,s)
% overloads subsref
  
switch s(1).type
  case '()'
  
    bM.mori = subsref(bM.mori,s(1));
    bM.N1 = subsref(bM.N1,s(1));
                
    if numel(s)>1
      [varargout{1:nargout}] = builtin('subsref',bM,s(2:end));
    else
      varargout{1} = bM;
    end
      
  otherwise
    [varargout{1:nargout}] = builtin('subsref',bM,s);
end
end
