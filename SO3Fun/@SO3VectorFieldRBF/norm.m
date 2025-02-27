function SO3F = norm(SO3VF)
% point-wise norm of the vector field
%
% Syntax
%   SO3F = norm(SO3VF)
%
% Input
%  SO3VF - @SO3VectorFieldRBF 
%
% Output
%  SO3F - @SO3FunRBF
%


SO3F = SO3FunRBF.approximate(...
  @(rot) norm(SO3VF.eval(rot)),SO3VF.CS,SO3VF.SS);

end
