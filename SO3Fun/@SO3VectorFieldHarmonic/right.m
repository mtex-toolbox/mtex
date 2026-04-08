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

  % do quadrature
  if check_option(varargin,'check')
    bw = get_option(varargin,'bandwidth',SO3VF.bandwidth+1);
    SO3VF = SO3VectorFieldHandle(@(r) SO3VF.eval(r),SO3VF.hiddenCS,SO3VF.hiddenSS,SO3VF.tangentSpace);
    SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth',bw,varargin{:});
    return
  end

  % compute directly on frequency domain
  SO3VF = transformInternTangentSpace(SO3VF);

end

end

