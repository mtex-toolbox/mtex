function F = plus(F1, F2)
% impements F1 + F2
%
% Syntax
%   F = F1+F2
%   F = a+F1
%   F = F1+a
%

if isnumeric(F1) && length(F1) == 1
  s = size(F2);
  F = F2.subSet(':');
  F.fhat(1, :) = F.fhat(1, :)+F1;
  F = reshape(F, s);

elseif isnumeric(F2) && length(F2) == 1
  s = size(F1);
  F = F1.subSet(':');
  F.fhat(1, :) = F.fhat(1, :)+F2;
  F = reshape(F, s);

else
  [~, index] = max([F1.bandwidth, F2.bandwidth]);
  if index == 1
    F2.bandwidth = F1.bandwidth;
  else
    F1.bandwidth = F2.bandwidth;
  end

  F = F1;
  F.fhat = F1.fhat+F2.fhat;

end

end
