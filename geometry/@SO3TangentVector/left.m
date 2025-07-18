function SO3TV = left(SO3TV)
% change the representation of the tangent vectors to left sided
%
% Syntax
%   SO3TV = left(SO3TV)
%
% Input
%  SO3TV - @SO3TangentVector
%
% Output
%  SO3TV - @SO3TangentVector (left-sided tangent vectors)
%
% See also
% SO3TangentVector/SO3TangentVector SO3TangentVector/right

if SO3TV.tangentSpace.isRight
  % transform from right to left
  SO3TV = SO3TangentVector( rotation(SO3TV.rot).*SO3TV , SO3TV.rot, -SO3TV.tangentSpace,SO3TV.hiddenCS,SO3TV.hiddenSS);
end

end