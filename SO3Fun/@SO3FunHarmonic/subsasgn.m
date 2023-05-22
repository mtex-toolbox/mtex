function SO3F = subsasgn(SO3F, s, b)
% overloads subsasgn

if ~isa(SO3F,'SO3FunHarmonic') && ~isempty(b)
  SO3F = b;
  SO3F.fhat = [];
end

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(SO3F,s(1)), s(2:end), b); end
    
    s(1).subs = [':' s(1).subs];
    
    % remove functions
    if isempty(b)
      SO3F.fhat = subsasgn(SO3F.fhat,s(1),b);
      return
    end
    
    ensureCompatibleSymmetries(SO3F,b);

    [bw, I] = max([SO3F.bandwidth, b.bandwidth]);
    if I == 1
      b.bandwidth = bw;
    else
      SO3F.bandwidth = bw;
    end
        
    SO3F.fhat = subsasgn(SO3F.fhat,s(1),b.fhat);
        
  otherwise
    
    SO3F =  builtin('subsasgn',SO3F,s,b);    
end

end
