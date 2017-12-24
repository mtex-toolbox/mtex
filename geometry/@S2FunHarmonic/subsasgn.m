function sF = subsasgn(sF, s, b)
% overloads subsasgn

if ~isa(sF,'S2FunHarmonic') && ~isempty(b)
  sF = b;
  sF.fhat = [];
end

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(sF,s(1)), s(2:end), b); end
    
    s(1).subs = [':' s(1).subs];
    
    % remove functions
    if isempty(b)
      sF.fhat = subsasgn(sF.fhat,s(1),b);
      return
    end
    
    [bw, I] = max([sF.bandwidth, b.bandwidth]);
    if I == 1
      b.bandwidth = bw;
    else
      sF.bandwidth = bw;
    end
        
    sF.fhat = subsasgn(sF.fhat,s(1),b.fhat);
        
  otherwise
    
    sF =  builtin('subsasgn',sF,s,b);    
end

end
