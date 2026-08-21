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
  % transform from left to right - rotating keeps the class and the
  % reference, so only the label has to follow
  tS = -SO3TV.tangentSpace;
  SO3TV = inv(rotation(SO3TV.oriRef)) .* SO3TV;
  SO3TV.tangentSpace = tS;
end

end