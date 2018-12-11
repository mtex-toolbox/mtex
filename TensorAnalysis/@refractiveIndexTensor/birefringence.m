function [n,pMin,pMax,nMin,nMax] = birefringence(rI,vprop)
% birefringence from refractive index tensor
%
% Description
%
% Birefringence is the difference in light speed in anisotropic material.
% When entering an anisotrpic media plane polarised light migrating along
% the propagation direction vprop is split into two orthogonally vibrating
% waves that moves at different speed, the slowest with nmax and the faster
% wave with nmax. The values of nmin and nmax can be calculated from the
% refractive index tensor containg the three pricipal refractive index of
% the mineral, nalpha, nbeta and ngamma and the ligth propagation direction
% (vprop)  with repect to the crystal reference frame. The birefringence
% varies as function of the vprop and for each vprop coressponds to
% nmax-nmin. 
%
% Syntax
%
%   [n,nMin,nMax] = birefringence(rI,vprop)
%
% Input
%  rI    - @refractiveIndexTensor
%  vprop - propagation direction @vector3d
%
% Output
%  nMin - lowest refractive index for a given propagation direction
%  nMax - highest refractive index for a given propagation direction
%  n - difference between nMax and nMin
%  pMin - @vector3d polarization direction with the lowest refractive index 
%  pMax - @vector3d polarization direction with the highest refractive index 

%

% generate function ?
if nargin == 1 || isempty(vprop)

  M = 48;
  [vprop, W] = quadratureS2Grid(2*M);

  [n,pMin,pMax] = birefringence(rI,vprop);

  n = S2FunHarmonicSym.quadrature(vprop,n,rI.CS,'bandwidth',M,'weights',W);
  pMin = S2AxisFieldHarmonic.quadrature(vprop,pMin,'bandwidth',M,'weights',W);
  pMax = S2AxisFieldHarmonic.quadrature(vprop,pMax,'bandwidth',M,'weights',W);

  return
end

% first we need two arbitrary orthogonal directions orthogonal to vprop
p1 = orth(vprop(:));
p2 = rotation.byAxisAngle(vprop(:),90*degree) .* p1;

B11 = EinsteinSum(rI,[-1 -2],p1,-1,p1,-2);
B12 = EinsteinSum(rI,[-1 -2],p1,-1,p2,-2);
B22 = EinsteinSum(rI,[-1 -2],p2,-1,p2,-2);

[lambda,v1,v2] = eig2(B11,B12,B22);

n = lambda(:,2) - lambda(:,1);
if nargout > 1

 pMin = sum([p1,p2] .* v1,2);
 pMax = sum([p1,p2] .* v2,2);

end

if nargout > 2, nMin = lambda(:,1); nMax = lambda(:,2); end

end
