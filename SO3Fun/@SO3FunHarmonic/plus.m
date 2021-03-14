function SO3F = plus(SO3F1, SO3F2)
% impements SO3F1 + SO3F2
%
% Syntax
%   SO3F = SO3F1+SO3F2
%   SO3F = a+SO3F1
%   SO3F = SO3F1+a
%

if isnumeric(SO3F1) && length(SO3F1) == 1
  s = size(SO3F2);
  SO3F = SO3F2.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F1;
  SO3F = reshape(SO3F, s);

elseif isnumeric(SO3F2) && length(SO3F2) == 1
  s = size(SO3F1);
  SO3F = SO3F1.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F2;
  SO3F = reshape(SO3F, s);

else
  [~, index] = max([SO3F1.bandwidth, SO3F2.bandwidth]);
  if index == 1
    SO3F2.bandwidth = SO3F1.bandwidth;
  else
    SO3F1.bandwidth = SO3F2.bandwidth;
  end

  SO3F = SO3F1;
  SO3F.fhat = SO3F1.fhat+SO3F2.fhat;

end

end