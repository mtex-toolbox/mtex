classdef S2VectorField
% a class represeneting a vector field on the sphere

methods

end

methods (Abstract = true)

  f = eval(sF, v, varargin)

end

methods (Sealed = true)
  h = plot(sF,varargin)
end

methods(Static = true)
  v = theta(v);
  v = rho(v);
  v = normal(v);
  
  vF = polar(rRef);
  vF = oneSingularity(rRef);
  vF = sigma;
  
end

end
