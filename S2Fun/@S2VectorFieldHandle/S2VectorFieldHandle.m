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
    if isscalar(S2F)
       f = S2F.fun(v);
    else
      f = vector3d.zeros(numel(v),length(S2F));
      for k = 1:length(S2F)
        f(:,k) = reshape(S2F(k).fun(v),[],1);
      end
    end
  end
  
end

end
