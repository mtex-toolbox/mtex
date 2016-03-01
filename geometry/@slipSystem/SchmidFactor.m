function SF = SchmidFactor(sS,sigma)
% compute the Schmid factor 
%
% Syntax
%
%   SF = SchmidFactor(sS,v)
%   SF = SchmidFactor(sS,sigma)
%
% Input
%  sS - list of @slipSystem
%  v  - @vector3d - list of tension direction
%  sigma - stress @tensor
%
% Output
%  SF - size(sS) x size(sigma) matrix of Schmid factors
%

b = sS.b.normalize; %#ok<*PROPLC>
n = sS.n.normalize;

if isa(sigma,'vector3d')
  
  r = sigma.normalize;
  SF = dot_outer(r,b,'noSymmetry') .* dot_outer(r,n,'noSymmetry');
  
elseif isa(sigma,'tensor')
  
  SF = zeros(length(sigma),length(b));
  for i = 1:length(sS.b)
    SF(:,i) = double(EinsteinSum(sigma,[-1,-2],n(i),-1,b(i),-2));
  end
  
else
  
  error('Second argument should be either vector3d or stressTensor.')
  
end
end
