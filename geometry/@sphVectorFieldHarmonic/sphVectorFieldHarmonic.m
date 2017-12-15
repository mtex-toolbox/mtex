classdef sphVectorFieldHarmonic < sphVectorField
% a class represeneting a function on the sphere

properties
  sF_theta
  sF_rho
  sF_n
end

methods

  function sVF = sphVectorFieldHarmonic(sF_theta, sF_rho, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    sVF.sF_theta = sF_theta;
    sVF.sF_rho = sF_rho;
    if ( nargin > 2 ) && ( isa(varargin(1), 'sphFun') )
      sVF.sF_n = vargin(1);
    else
      sVF.sF_n = sphFunHarmonic(0);
    end

  end

end

end
