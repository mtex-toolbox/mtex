function SO3VF = left(SO3VF,varargin)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3VF = right(SO3VF)
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic  (the evaluation directly gives left-sided tangent vectors)
%

if strcmp(SO3VF.tangentSpace,'left')
  return
end

bw = get_option(varargin,'bandwidth',SO3VF.bandwidth+1);
SO3VF = left@SO3VectorField(SO3VF);
SO3VF = SO3VectorFieldHarmonic(SO3VF,'bandwidth',bw,varargin{:});

end