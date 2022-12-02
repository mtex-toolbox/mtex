function SO3F = plus(SO3F1,SO3F2)
% overloads |SO3F1 + SO3F2|
%
% Syntax
%   SO3F = SO3F1 + SO3F2
%   SO3F = a + SO3F1
%   SO3F = SO3F1 + a
%
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%  a - double
%
% Output
%  SO3F - @SO3FunHarmonic
%


if isnumeric(SO3F1) 
  s = size(SO3F2);
  SO3F = SO3F2.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F1(:).';
  SO3F = reshape(SO3F, s);
  return
end
if isnumeric(SO3F2)
  s = size(SO3F1);
  SO3F = SO3F1.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F2(:).';
  SO3F = reshape(SO3F, s);
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
SO3F1 = SO3FunHarmonic(SO3F1);
SO3F2 = SO3FunHarmonic(SO3F2);

[~, index] = max([SO3F1.bandwidth, SO3F2.bandwidth]);
if index == 1
  SO3F2.bandwidth = SO3F1.bandwidth;
else
  SO3F1.bandwidth = SO3F2.bandwidth;
end

SO3F = SO3F1;
SO3F.fhat = SO3F1.fhat + SO3F2.fhat;


end