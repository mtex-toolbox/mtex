function SF = SchmidFactor(sS,sigma,varargin)
% compute the Schmid factor 
%
% Syntax
%
%   SFfun = SchmidFactor(sS) % returns spherical function
%   SF = SchmidFactor(sS,v)
%   SF = SchmidFactor(sS,sigma)
%   SF = SchmidFactor(sS,sigma,'relative')
%
% Input
%  sS - list of @slipSystem
%  v  - @vector3d list of tension direction
%  sigma - @stressTensor
%
% Output
%  SFfun - size(sS) x 1 list of @S2FunHarmonic
%  SF - size(sS) x size(sigma) matrix of Schmid factors
%   

b = sS.b.normalize; %#ok<*PROPLC>
n = sS.n.normalize;

% compute the relative Schmid factor by dividing by the critical resolved
% shear stress for every slip system
if check_option(varargin,'relative')
   b = b./ sS.CRSS;
end

% Schmid factor with respect to a tension direction
if nargin == 1 || (isnumeric(sigma) && isempty(sigma))
  
  SF = S2FunHarmonic.quadrature(@(v) sS.SchmidFactor(v,varargin{:}),'bandwidth',64);
    
elseif isa(sigma,'vector3d')
  
  r = sigma.normalize;
  SF = dot_outer(r,b,'noSymmetry') .* dot_outer(r,n,'noSymmetry');
  
% Schmid factor with respect to a stress tensor
elseif isa(sigma,'stressTensor')
  
  % normalize the stress tensor
  sigma = sigma.normalize;
  
  if length(sigma) == 1
    SF = EinsteinSum(sigma,[-1,-2],n,-1,b,-2);
    SF = reshape(SF,size(sS));
  else
    SF = zeros(length(sigma),length(b));
  
    for i = 1:length(sS.b)
      SF(:,i) = EinsteinSum(sigma,[-1,-2],n(i),-1,b(i),-2);
    end
  end
    
else
  
  error('Second argument should be either vector3d or stressTensor.')
  
end
end
