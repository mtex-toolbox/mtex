function varargout = subsref(T,s)
%overloads subsref

if strcmp(s(1).type,'{}')

  s(1).type = '()';
  
  if T.rank>1 && length(s(1).subs) == 1
  
    MLocal = reshape(T.M,[3^T.rank size(T) 1]);
    s.subs = [s.subs repcell(':',1,ndims(T.M)-T.rank)];
    varargout{1} = squeeze(subsref(MLocal,s));
  
  elseif T.rank == 4 && length(s(1).subs) == 2
    
    M = tensor42(T.M,T.doubleConvention);
    
    s.subs = [s.subs repcell(':',1,ndims(M)-2)];
    
    varargout{1} = squeeze(subsref(M,s));
    
  else
    
    s(1).subs = [s(1).subs repcell(':',1,ndims(T.M)-T.rank)];
    
    T = squeeze(subsref(T.M,s(1)));
    if length(s) > 1
      [varargout{1:nargout}] = subsref(T,s(2:end));
    else
      varargout{1} = T;
    end
  end
  
  return
  
elseif strcmp(s(1).type,'()')

  s(1).subs = [repcell(':',1,T.rank) s(1).subs];
    
  T.M = subsref(T.M,s(1));
      
  if numel(s)==1
    varargout{1} = T;
    return;
  else
    s = s(2:end);
  end
end
  
if isOption(T,s(1).subs)
  if numel(s)==1
    varargout{1} = T.opt.(s(1).subs);
  else
    [varargout{1:nargout}] = subsref(T.opt.(s(1).subs),s(2:end));
  end
  %subsref@dynOption(T,s);
else
  [varargout{1:nargout}] = builtin('subsref',T,s);
end
