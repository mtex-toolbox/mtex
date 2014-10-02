function T = subsasgn(T,s,b)
% overloads subsasgn


switch s.type

  case '()'
  
   s.subs = [repcell(':',1,T.rank) s.subs]; 
    
   b = tensor(b);
   
   T.M = subsasgn(T.M,s,b.M);
    
  case '{}'
    
    if T.rank == 4
      M = tensor42(T.M,T.doubleConvention);
      M = subsasgn(M,s,b);
      T.M = tensor24(M,T.doubleConvention);
    elseif T.rank == 3
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
