function SO3F = inv(SO3F)      
% Define the inverse function $g$ of an SO3FunRBF $f$ by $g(R^{-1}) = f(R)$
% for all rotations $R\in SO(3)$.
%
% Syntax
%   SO3F = inv(F)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  SO3F - @SO3FunRBF
%  

% stop in simple case
if SO3F.bandwidth == 0 || SO3F.antipodal==true
  return
end

% exchange wigner coefficients
SO3F.center = inv(SO3F.center);

end