function SO3TV = right(SO3TV)
% change the representation of the tangent vectors to right sided
%
% Syntax
%   SO3TV = right(SO3TV)
%
% Input
%  SO3TV - @SO3TangentVector
%
% Output
%  SO3TV - @SO3TangentVector (right-sided tangent vectors)
%

if SO3TV.tangentSpace.isLeft
  % transform from left to right
  SO3TV = SO3TangentVector( inv(rotation(SO3TV.oriRef)) .* SO3TV , SO3TV.oriRef, -SO3TV.tangentSpace);
end

end