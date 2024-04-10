function SO3VF = right(SO3VF,varargin)
% change the inner representation of the tangent vectors to right sided
%
% Syntax
%   SO3VF = right(SO3VF)
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic  (the evaluation directly gives right-sided tangent vectors)
%

if SO3VF.internTangentSpace.isRight, return, end

% check for conservative vector field and compute gradient of antiderivative
c = SO3VF.curl;
n = sqrt(sum(norm(c.SO3F).^2));
if n<1e-3
  SO3VF = SO3VF.antiderivative('conservative').grad(-SO3VF.internTangentSpace);
  return
end

% do quadrature
bw = get_option(varargin,'bandwidth',SO3VF.bandwidth+1);
SO3VF = right@SO3VectorField(SO3VF);
SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth',bw,varargin{:});

end