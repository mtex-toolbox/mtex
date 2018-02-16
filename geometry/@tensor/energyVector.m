function E = energyVector(C,x,V,P,rho)
% Calculates Energy velocity vector (km/s)
%
% Description
% Energy velocity for lossless elastic medium (i.e. no attenuation)
% Good proxy for group velocity, which typically has some energy loss
% The formula is given by
% F.I. Fedorov(1968)Theory of Elastic Waves in Crystals, 375 pp. New York: Penum Press.
%
% Ve_i = C_ijkl P_j P_l X_k / rho*V
% 
% Syntax
%
%   E = velocityVector(C,X,V,P,rho)
%   E = velocityVector(C,[],V,P,rho)
%
% Input
%  C - Elastic stiffness tensor (units GPa)
%  x - Propagation direction (unit vector)
%  V - plane wave velocity (unit km/s) e.g. vp,vs1 or vs2
%  P - plane wave polarization vector (unit vector) e.g. pp,ps1 or ps2
%  rho - density in g/cm3
%
% Output
%  E = Energy velocity vector (units km/s)
%
% N.B. E_magnitude should be equal or more than plane wave velocity vp, vs1 or vs2
% 
% David Mainprice 6/02/2018

% return a function if required
if isempty(x)
  E = S2VectorFieldHarmonic.quadrature(@(x) velocityVector(C,x,V.eval(x),P.eval(x),rho),'bandwidth',P.bandwidth,C.CS);
  return
end

% make X and P to be unit vectors
x = x.normalize;
P = P.normalize;

% E_vector
E = vector3d(EinsteinSum(C,[1 -2 -3 -4],P(:),-2,P(:),-4,x(:),-3))./rho ./V(:);

end