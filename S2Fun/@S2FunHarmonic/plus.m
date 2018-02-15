function sF = plus(sF1, sF2)
% impements sF1 + sF2
%
% Syntax
%   sF = sF1+sF2
%   sF = a+sF1
%   sF = sF1+a
%

if isnumeric(sF1) && length(sF1) == 1
  s = size(sF2);
  sF = sF2.subSet(':');
  sF.fhat(1, :) = sF.fhat(1, :)+sF1;
  sF = reshape(sF, s);

elseif isnumeric(sF2) && length(sF2) == 1
  s = size(sF1);
  sF = sF1.subSet(':');
  sF.fhat(1, :) = sF.fhat(1, :)+sF2;
  sF = reshape(sF, s);

else
  [val, index] = max([sF1.bandwidth, sF2.bandwidth]);
  if index == 1
    sF2.bandwidth = sF1.bandwidth;
  else
    sF1.bandwidth = sF2.bandwidth;
  end

  sF = sF1;
  sF.fhat = sF1.fhat+sF2.fhat;

end

end
