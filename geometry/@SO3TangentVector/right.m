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
  SO3TV = SO3TangentVector( inv(rotation(SO3TV.rot)) .* SO3TV , SO3TV.rot, -SO3TV.tangentSpace,SO3TV.hiddenCS,SO3TV.hiddenSS);
end

end