function SO3F = WignerDmap(N,varargin)
% create harmonic Representation of the Wigner-D function with harmonic
% degree N and index k,l : D^n_{k,l}
%
% Syntax
%   SO3F = WignerDmap(N,k,l)
%   SO3F = WignerDmap(N,'full')
%
% Input
%   N   - harmonic degree of Wigner-D function
%   k,l - indices of Wigner-D function
%
% Output
%   SO3F - @SO3FunHarmonic
%
% Options
%   'full'    - creates f(x) = sum_{k,l} D_{k,l}^N (x), i.e. sum of all 
%               Wigner-D functions with harmonic degree N
%


if check_option(varargin,'full')
  
  len = deg2dim(N+1)-deg2dim(N);
  fhat = [zeros(deg2dim(N),1);ones(len,1)];
  SO3F = SO3FunHarmonic(fhat);
  
else
  
  s = size(N);
  
  n = N(:); k = varargin{1}(:); l = varargin{2}(:); 

  % Probably point wise also in deg2dim
  deg = n.*(2*n-1).*(2*n+1)/3;
  
  oneind = (deg+n+1+l+(2*n+1).*(n+k)) + (0:length(n)-1)'*deg2dim(max(n+1));
  
  fhat = zeros(deg2dim(max(n+1)),length(n));
  fhat(oneind) = 1;

  SO3F = SO3FunHarmonic(fhat);
  SO3F = reshape(SO3F,s);
  
end

SO3F.isReal=0;


end