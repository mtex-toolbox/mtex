function sF = subsasgn(sF1, s, b)
% overloads subsasgn

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(sF1,s(1)), s(2:end), b); end
      
    if isnumeric(b)
      b = S2FunHarmonic(b)
    end
    [bandwidth, I] = max([sF1.bandwidth, b.bandwidth]);
    if I == 1
      b.bandwidth = sF1.bandwidth;
    else
      sF1.bandwidth = b.bandwidth;
    end
    t = substruct('()', {':', s(1).subs{:}});
    sF = S2FunHarmonic(subsasgn(sF1.fhat, t, b.fhat));
  otherwise
    
    sF =  builtin('subsasgn',sF1,s,b);    
end

end
