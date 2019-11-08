function T = subsasgn(T,s,b)
% overloads subsasgn

if isempty(T)
  T = b;
  T.M = zeros(repmat(3,1,b.rank));
end


switch s(1).type

  case '()'
  
   s(1).subs = [repcell(':',1,T.rank) s(1).subs]; 
    
   b = tensor(b);
   
   T.M = subsasgn(T.M,s,b.M);
    
  case '{}'
    
    s(1).type = '()';
    s(1).subs = [s(1).subs,repcell(':',1,ndims(T))];
    if T.rank == 4 && length(s(1).subs) == 2 + ndims(T)
      M = tensor42(T.M,T.doubleConvention);
      M = subsasgn(M,s,b);
      T.M = tensor24(M,T.doubleConvention);
    elseif T.rank == 3 && length(s(1).subs) == 2 + ndims(T)
      M = tensor32(T.M,T.doubleConvention);
      M = subsasgn(M,s,b);
      T.M = tensor23(M,T.doubleConvention);
    else
      T.M = subsasgn(T.M,s,b);
    end
    
  otherwise
    
    try
      T =  builtin('subsasgn',T,s,b);
    catch
      T = subsasgn@dynOption(T,s,b);
    end
          
end
