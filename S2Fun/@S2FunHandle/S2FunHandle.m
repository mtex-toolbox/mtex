classdef S2FunHandle < S2Fun
% spherical function given by a function handle
  
properties
  fun
  antipodal = false
  bandwidth = getMTEXpref('maxS2Bandwidth')
end


methods
  function S2F = S2FunHandle(fun)
    S2F.fun = fun;
  end
  
  function f = eval(S2F,v)
    f = S2F.fun(v+0.000001*xvector);
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
