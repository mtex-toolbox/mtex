function T = subsref(T,s)
%overloads subsref

switch s.type

  case '()'
  
   s.subs = [repcell(':',1,T.rank) s.subs]; 
    
   T.M = subsref(T.M,s);
    
  case '{}'

    s.type = '()';
    if T.rank == 4 && numel(s.subs)==2
      M = tensor42(T.M,T.doubleConvention);
      T = subsref(M,s);
    elseif T.rank==3 && numel(s.subs)==2
      M = tensor32(T.M,T.doubleConvention);
      T = subsref(M,s);
    else
      T = subsref(T.M,s);
    end
    
end


