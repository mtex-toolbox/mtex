function f = antiderivative(SO3VF,varargin)
% antiderivative of an vector field
%
% Syntax
%   F = SO3VF.antiderivative % compute the antiderivative
%   f = SO3VF.antiderivative(rot) % evaluate the antiderivative in rot
%
% Input
%  SO3VF - @SO3VectorField
%  rot  - @rotation / @orientation
%
% Output
%  F - @SO3FunHarmonic
%  f - @double
% 
% See also
% SO3VectorFieldHarmonic/antiderivative SO3FunHarmonic/grad SO3VectorFieldHarmonic/curl SO3VectorFieldHarmonic

% check whether the vector field is conservative
if ~check_option(varargin,'conservative')
  c = SO3VF.curl;
  n = norm(norm(c));
  if n>1e-3
    error(['The vector field is not conservative (not the gradient of some SO3Fun),' ...
           ' since the curl = ',n,' is not vanishing.'])
  end
end

SO3VF = SO3VectorFieldHarmonic(SO3VF);
f = antiderivative(SO3VF,varargin{:},'conservative');

end