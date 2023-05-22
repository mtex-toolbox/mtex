classdef S2VectorFieldHarmonic < S2VectorField
% a class represeneting a function on the sphere

properties
  sF
end

properties(Dependent = true)
  x
  y
  z
  bandwidth
end

methods

  function sVF = S2VectorFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    sVF.sF = sF(:);
    
  end

  function bw = get.bandwidth(sVF), bw = sVF.sF.bandwidth; end
  function sVF = set.bandwidth(sVF,bw), sVF.sF.bandwidth = bw; end
  function x = get.x(sVF), x = sVF.sF(1); end
  function y = get.y(sVF), y = sVF.sF(2); end
  function z = get.z(sVF), z = sVF.sF(3); end
  function sVF = set.x(sVF, x), sVF.sF(1) = x; end
  function sVF = set.y(sVF, y), sVF.sF(2) = y; end
  function sVF = set.z(sVF, z), sVF.sF(3) = z; end

end

methods(Static = true)
  sVF = quadrature(f, varargin)
  sVF = approximation(f, varargin)
  function sVF = normal
    sVF = S2VectorFieldHarmonic.quadrature(@(v) v,'bandwidth',2);
  end
end

end
