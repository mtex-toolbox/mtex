classdef S2FunHandle < S2Fun
% a class represeneting a function on the sphere
  
properties
  fun
  antipodal = false
end


methods
  function S2F = S2FunHandle(fun)
    S2F.fun = fun;
  end
  
  function f = eval(S2F,v)
    f = S2F.fun(v);
  end
  
end


methods (Static = true)
  
  function S2F = Kachanov(lambda)
    
    S2F = S2FunHandle(@(v) fun(v,lambda));
    
    function values = fun(v,lambda)

      phi = v.theta;
      values =  ((lambda.^2 + 1) * exp(-lambda * phi) + ...
        lambda*exp((-lambda*pi)/2))./(2*pi);
      
      values = values(:);
      
    end
    
  end
    
    
end


end
