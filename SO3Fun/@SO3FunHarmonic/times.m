function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%  a - double
%
% Output
%  SO3F - @SO3FunHarmonic
%

if isnumeric(SO3F1)
  SO3F = SO3F2;
  SO3F.fhat = reshape(SO3F1,[1,size(SO3F1)]).*SO3F.fhat;
  return
end
if isnumeric(SO3F2)
  SO3F = SO3F2 .* SO3F1;
  return
end

SO3F = times@SO3Fun(SO3F1,SO3F2);
SO3F = SO3FunHarmonic(SO3F,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));

end
