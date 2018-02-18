function sF = mtimes(sF1, sF2)
%
% Syntax
%  sF = sF1 * sF2
%  sF = a * sF1
%  sF = sF1 * a
%

if isnumeric(sF1)
  sF = sF2;
  sF.fhat = sF1 * sF.fhat;
elseif isnumeric(sF2)
  sF = sF1;
  sF.fhat = sF2 * sF.fhat;
else
  warning('not implemented yet; use .* instead');
end

end
