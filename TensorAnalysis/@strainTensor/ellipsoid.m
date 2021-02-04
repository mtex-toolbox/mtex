function [fe,qe] = ellipsoid(E)
% Length (1+e) and direction of principal axes of strain ellipsoid from
% finite, lagrangian/eulerian strain tensor E with eigenvalues lambda
% with
% (1+e) = sqrt(1+2*lambda) for a Lagranage strain tensor (default)
% (1+e) = sqrt(1-2*lambda) for a Euler strain tensor
% Syntax
%   [fe,qe] = ellipsoid(E)
%
% Input
%  E -  @strainTensor
%
% Output
%  fe - directions of prinicpal axes of strain ellipsoid @vector3d
%  qe - length of ellipse axes (1+e)

[fe,qe] = eig(E);
 if strcmp(E.type,'Euler')
     qe = sqrt(1-2*qe);
 else
    qe = sqrt(1+2*qe);
 end
end
