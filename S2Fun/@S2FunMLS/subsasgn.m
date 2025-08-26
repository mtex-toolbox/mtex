function S2F = subsasgn(S2F, s, b)
% overloads subsasgn

if ~isa(S2F,'S2FunMLS') && ~isempty(b)
  S2F = b;
  S2F.values = [];
end

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(S2F,s(1)), s(2:end), b); end
    
    s(1).subs = [':' s(1).subs];
    
    % remove functions
    if isempty(b)
      S2F.values = subsasgn(S2F.values,s(1),b);
      return
    end
    
    ensureCompatibleSymmetries(S2F,b);

    [bw, I] = max([S2F.bandwidth, b.bandwidth]);
    if I == 1
      b.bandwidth = bw;
    else
      S2F.bandwidth = bw;
    end
        
    S2F.values = subsasgn(S2F.values,s(1),b.values);
        
  otherwise
    
    S2F =  builtin('subsasgn',S2F,s,b);    
end

end
