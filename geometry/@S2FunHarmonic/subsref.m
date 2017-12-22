function varargout = subsref(sF, s)
% overloads subsref

switch s(1).type
  case '()'
    t = substruct('()', {':', s(1).subs{:}});
    sF = S2FunHarmonic(builtin('subsref', sF.fhat, t));
    if numel(s)>1
      [varargout{1:nargout}] = subsref(sF, s(2:end));
    else
      varargout{1} = sF;
    end  

  otherwise
    [varargout{1:nargout}] = builtin('subsref', sF, s);

end
end
