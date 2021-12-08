classdef S2VectorFieldHandle < S2VectorField
% a class represeneting a function on the sphere
  
properties
  fun
  antipodal = false
end

methods
  function S2F = S2VectorFieldHandle(fun)
    S2F.fun = fun;
  end
  
  function f = eval(S2F,v)
    for k = 1:length(S2F)
      f(:,k) = S2F(k).fun(v);
    end
  end
  
end

end
