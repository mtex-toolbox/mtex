function SO3TV = right(SO3TV,rot)
% change the representation of the tangent vectors to right sided
%
% Syntax
%   SO3TV = right(SO3TV,rot)
%
% Input
%  SO3TV - @SO3TangentVector
%  rot - @rotation of the corresponding tangent space
%
% Output
%  SO3TV - @SO3TangentVector (right-sided tangent vectors)
%

if strcmp(SO3TV.tangentSpace,'right')
  return
end

SO3TV = SO3TangentVector( inv(rot).*SO3TV , 'right' );

end