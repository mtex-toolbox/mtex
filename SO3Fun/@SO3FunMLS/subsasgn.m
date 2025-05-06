function SO3F = subsasgn(SO3F, s, b)
% overloads subsasgn

if ~isa(SO3F,'SO3FunMLS') && ~isempty(b)
  SO3F = b;
  SO3F.values = [];
end

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(SO3F,s(1)), s(2:end), b); end
    
    s(1).subs = [':' s(1).subs];
    
    % remove functions
    if isempty(b)
      SO3F.values = subsasgn(SO3F.values,s(1),b);
      return
    end
    
    ensureCompatibleSymmetries(SO3F,b);

    [bw, I] = max([SO3F.bandwidth, b.bandwidth]);
    if I == 1
      b.bandwidth = bw;
    else
      SO3F.bandwidth = bw;
    end
        
    SO3F.values = subsasgn(SO3F.values,s(1),b.values);
        
  otherwise
    
    SO3F =  builtin('subsasgn',SO3F,s,b);    
end

end
