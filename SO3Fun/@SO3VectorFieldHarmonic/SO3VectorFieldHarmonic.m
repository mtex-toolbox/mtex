classdef SO3VectorFieldHarmonic < SO3VectorField
% a class represeneting a function on the sphere

properties
  SO3F
  antipodal = false
end

properties(Dependent = true)
  x
  y
  z
  bandwidth
  SLeft
  SRight
end

methods

  function SO3VF = SO3VectorFieldHarmonic(SO3F, varargin)
    % initialize a spherical vector field
    
    if nargin == 0, return; end
    SO3VF.SO3F = SO3F(:);

  end

  function bw = get.bandwidth(SO3VF), bw = SO3VF.SO3F.bandwidth; end
  function SO3VF = set.bandwidth(SO3VF,bw), SO3VF.SO3F.bandwidth = bw; end
  function x = get.x(SO3VF), x = SO3VF.SO3F(1); end
  function y = get.y(SO3VF), y = SO3VF.SO3F(2); end
  function z = get.z(SO3VF), z = SO3VF.SO3F(3); end
  function SO3VF = set.x(SO3VF, x), SO3VF.SO3F(1) = x; end
  function SO3VF = set.y(SO3VF, y), SO3VF.SO3F(2) = y; end
  function SO3VF = set.z(SO3VF, z), SO3VF.SO3F(3) = z; end

  function SLeft = get.SLeft(SO3VF), SLeft = SO3VF.SO3F.SLeft; end
  function SRight = get.SRight(SO3VF), SRight = SO3VF.SO3F.SRight; end
  
  function SO3VF = set.SLeft(SO3VF,SLeft), SO3VF.SO3F.SLeft = SLeft; end
  function SO3VF = set.SRight(SO3VF,SRight), SO3VF.SO3F.SRight = SRight; end
  
  
end

methods(Static = true)
  SO3VF = quadrature(f, varargin)
  SO3VF = approximation(f, varargin)
end

end
