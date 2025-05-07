function SO3F = inv(SO3F)      
% Define the inverse function $g$ of an SO3FunRBF $f$ by $g(R^{-1}) = f(R)$
% for all rotations $R\in SO(3)$.
%
% Syntax
%   SO3F = inv(F)
%
% Input
%  SO3F - @SO3FunMLS
%
% Output
%  SO3F - @SO3FunMLS
%  

% stop in simple case
if isempty(SO3F.nodes) || SO3F.antipodal==true
  return
end

% exchange the nodes
SO3F.nodes = inv(SO3F.nodes);

end