function value = mean(SO3F, dim, varargin)
% calculates the mean value for an SO3FunRBF
%
% Syntax
%   value = mean(SO3F)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  value - double
%

if nargin == 1

  value = reshape(sum(SO3F.weights,1) * SO3F.psi.A(1),size(SO3F)) + SO3F.c0;
  if isalmostreal(value), value = real(value); end

else
  
  SO3F.weights = full(mean(SO3F.weights,dim+1,varargin{:}));
  value = SO3F;
  
end

end
