function SO3VF = mrdivide(SO3VF,s)
% overload the / operator, i.e. one can now write @SO3VectorField / 2  in 
% order to scale an SO3VectorField.
% Syntax
%   SO3VF = SO3VF / 2
% 
% Input
%  SO3VF - @SO3VectorField
%  s    - constant
%
% Output
%  SO3VF - @SO3VectorField
%

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

SO3VF = times(SO3VF,inv(s));

end