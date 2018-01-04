classdef S2VectorFieldHarmonic < S2VectorField
% a class represeneting a function on the sphere

properties
  sF;
end

methods

  function sVF = S2VectorFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    if length(sF) == 3
      sVF.sF = sF(:);
    end

  end

end

methods(Static = true)
  sVF = quadrature(f, varargin)
end

end
