function [fe, qe, Ea] = finiteStrain(L,n)
% derive finte strain axes and magnitudes from deformation tensor
% after n-steps (in strain rate units of L)
% using the solution of Provost et al.2014 doi:10.1029/2001JB001734
%
% Input
%  L        -  velocityGradientTensor
%  n        -  time step in units of strainrate*2 of L
%
% Output
%  fe       - finite strain ellipsoid axis directions (vector3d)
%  qe       - length of ellipse axes
%  Ea       - finite strain tensor (Langrange)

% compute the deformation gradient tensor or Langranian position gradient tensor
F = expm(L * n); 

% right Cauchy-Green deformation tensor 
C = F'*F;

% Green-Lagrangian strain tensor E = 0.5(C-I) -ref. to undeformed
Ea = strainTensor(0.5*(C-eye(3)));

% strain ellipsoid parameters from deformation tensor
% [f,q] = eig(C);
% q = sqrt(q);

% strain ellipsoid parameters from strain tensor
[fe,qe] = eig(Ea);
qe = sqrt(1+2*qe);

end

