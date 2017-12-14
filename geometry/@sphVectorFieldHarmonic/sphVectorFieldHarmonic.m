classdef sphVectorFieldHarmonic < sphVectorField
% a class represeneting a function on the sphere

properties
  theta
  rho
  n
end

methods

  function sVF = sphVectorFieldHarmonic(sF_theta, sF_rho, varargin)
  % initialize a spherical vector field
  if nargin == 0, return; end

  sVF.theta = sF_theta;
  sVF.rho = sF_rho;
  if nargin > 2 & isa(varargin(1), 'sphFun')
    sVF.n = vargin(1);
  else
    sVF.n = 0;
  end

  end

end

end
