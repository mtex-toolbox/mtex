function SO3VF = right(SO3VF,varargin)
% change the inner representation of the tangent vectors to right sided
%
% Syntax
%   SO3VF = right(SO3VF)
%   SO3VF = right(SO3VF),'internTangentSpace')
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic  (the evaluation directly gives right-sided tangent vectors)
%
% Options
%  internTangentSpace - Change the intern tangent space representation of SO3VF to right
%

% change outer tangent space representation to right
SO3VF.tangentSpace = -abs(SO3VF.tangentSpace);


if SO3VF.internTangentSpace.isLeft && check_option(varargin,'internTangentSpace')

  % check for conservative vector field and compute gradient of antiderivative
  c = SO3VF.curl;
  n = sqrt(sum(norm(c.SO3F).^2));
  if n<1e-3
    SO3VF = SO3VF.antiderivative('conservative').grad(-SO3VF.internTangentSpace);
    return
  end

  % do quadrature
  % error('test this')
  bw = get_option(varargin,'bandwidth',SO3VF.bandwidth+1);
  SO3VF = SO3VectorFieldHandle(@(r) SO3VF.eval(r),SO3VF.hiddenCS,SO3VF.hiddenSS,SO3VF.tangentSpace);
  SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth',bw,varargin{:});

end

end