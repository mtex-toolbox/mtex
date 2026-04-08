function SO3VF = left(SO3VF,varargin)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3VF = left(SO3VF)
%   SO3VF = left(SO3VF,'internTangentSpace')
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorField  (the evaluation directly gives left-sided tangent vectors)
%
% Options
%  internTangentSpace - Change the intern tangent space representation of SO3VF to left
% 

% change outer tangent space representation to left
SO3VF.tangentSpace = abs(SO3VF.tangentSpace);

if SO3VF.internTangentSpace.isRight && check_option(varargin,'internTangentSpace')

  % do quadrature
  bw = get_option(varargin,'bandwidth',SO3VF.bandwidth+1);
  f = SO3FunHandle(@(r) SO3VF.eval(r).xyz,SO3VF.CS);
  SO3VF = SO3VectorFieldHarmonic(f,'bandwidth',bw,SO3VF.hiddenCS,SO3VF.hiddenSS,SO3VF.tangentSpace);

end

end