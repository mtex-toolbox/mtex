function SO3F = WignerDmap(N,varargin)
% create harmonic Representation of the Wigner-D function with harmonic
% degree N
%
% Syntax
%   SO3F = WignerDmap(N)
%   SO3F = WignerDmap(N,'full')
%   SO3F = WignerDmap(N,'single',[k,l])      k,l \in (-N,N)
%
% Input
%   N - harmonic degree of Wigner-D function
%
% Output
%   SO3F - @SO3FunHarmonic
%
% Options
%   'full'    - creates f(x) = sum_{k,l} D_{k,l}^n (x)
%   'single'  - creates a single of functions D_{k,l}^n for one index of k,l
%

len = deg2dim(N+1)-deg2dim(N);

if check_option(varargin,'full')
  
  fhat = [zeros(deg2dim(N),1);ones(len,1)];
  SO3F = SO3FunHarmonic(fhat);
  
elseif check_option(varargin,'single')
  
  ind = get_option(varargin,'single')+N+1;
  n = deg2dim(N)+(ind(2)-1)*(2*N+1)+ind(1);
  v=zeros(deg2dim(N+1),1); v(n)=1;
  SO3F=SO3FunHarmonic(v);
  
else
  
  fhat = reshape([zeros(deg2dim(N),len);eye(len)],deg2dim(N+1),2*N+1,2*N+1);
  SO3F = SO3FunHarmonic(fhat);
  
end

SO3F.isReal=0;


end