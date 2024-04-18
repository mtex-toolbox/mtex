function sF = mtimes(sF1, sF2)
%
% Syntax
%   sF = sF1 * sF2
%   sF = a * sF1
%   sF = sF1 * [1;1]
%

if isnumeric(sF1)
  sF = sF2;
  sF.fhat = sF1 * sF.fhat;
elseif isnumeric(sF2)
   sF = (sF2.' * sF1.').';
  return
else
  error('not implemented yet; use .* or conv() instead');
end

end
