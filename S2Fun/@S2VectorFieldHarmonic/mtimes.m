function sVF = mtimes(sVF1, sVF2)
%
% Syntax
%   sF = sF1 * sF2
%   sF = a * sF1
%   sF = sF1 * a
%

if isnumeric(sVF1)
  sVF = sVF2;
  sVF.sF = sVF.sF.*sVF1;
elseif isnumeric(sVF2)
  sVF = sVF1;
  sVF.sF = sVF.sF.*sVF2;
end

end
