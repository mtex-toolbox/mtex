classdef S2VectorFieldHarmonic < S2VectorField
% a class represeneting a function on the sphere

properties
  sF;
end

properties(Dependent = true)
  x;
  y;
  z;
end

methods

  function sVF = S2VectorFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    if length(sF) == 3
      sVF.sF = sF(:);

    elseif length(sF) == 2
      f = @(v) ...
        sF(1).eval(v)./sin(v.theta).^2.*S2VectorField.rho(v)+ ...
        sF(2).eval(v).*S2VectorField.theta(v);

      sVF = S2VectorFieldHarmonic.quadrature(@(v) f(v));
    end

  end

  function x = get.x(sVF), x = SVF(1); end
  function y = get.y(sVF), y = SVF(2); end
  function z = get.z(sVF), z = SVF(3); end
  function set.x(sVF, x), SVF(1) = x; end
  function set.y(sVF, y), SVF(2) = y; end
  function set.z(sVF, z), SVF(3) = z; end

end

methods(Static = true)
  sVF = quadrature(f, varargin)
end

end
