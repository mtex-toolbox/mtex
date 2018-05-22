function [n,nMin,nMax] = birefringence(rI,vprop)
% birefringence from refractive index tensor
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
%  n - MISSING
%  nMin - MISSING
%  nMax - MISSING
%

% generate function ?
if nargin == 1 || isempty(vprop)
  
  M = 48;
  [vprop, W] = quadratureS2Grid(2*M);
  
  [n,nMin,nMax] = birefringence(rI,vprop);
  
  n = S2FunHarmonicSym.quadrature(vprop,n,rI.CS,'bandwidth',M,'weights',W);
  nMin = S2AxisFieldHarmonic.quadrature(vprop,nMin,'bandwidth',M,'weights',W);
  nMax = S2AxisFieldHarmonic.quadrature(vprop,nMax,'bandwidth',M,'weights',W);
  
  return
end

% first we need two arbitrary orthogonal directions orthogonal to vprop
p1 = orth(vprop(:));
p2 = rotation('axis',vprop(:),'angle',90*degree) .* p1;

B11 = EinsteinSum(rI,[-1 -2],p1,-1,p1,-2);
B12 = EinsteinSum(rI,[-1 -2],p1,-1,p2,-2);
B22 = EinsteinSum(rI,[-1 -2],p2,-1,p2,-2);

[lambda,v1,v2] = eig2(B11,B12,B22);

n = lambda(:,2) - lambda(:,1);
if nargout > 1
  
 nMin = sum([p1,p2] .* v1,2); 
 nMax = sum([p1,p2] .* v2,2); 
 
 %nMin = sum([p1,p2] .* squeeze(v(:,1,:)).',2);
 %nMax = sum([p1,p2] .* squeeze(v(:,2,:)).',2);
  
end

end