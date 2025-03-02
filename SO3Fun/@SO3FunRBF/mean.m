function value = mean(SO3F, dim, varargin)
% calculates the mean value for an SO3FunRBF
%
% Syntax
%   value = mean(SO3F)
%   value = mean(SO3F, dim)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  value - double
%

value = SO3F.c0;

if nargin == 1
  
  if ~isempty(SO3F.weights)
    value = value + reshape(sum(SO3F.weights,1) * SO3F.psi.A(1),size(SO3F));
  end
  if isalmostreal(value), value = real(value); end

else
  
  SO3F.weights = full(mean(SO3F.weights,dim+1,varargin{:}));
  value = mean(value,dim+1,varargin{:}) + SO3F;
  
end

end
