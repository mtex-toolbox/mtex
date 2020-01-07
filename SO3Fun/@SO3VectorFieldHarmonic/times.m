function sVF = times(sVF1,sVF2)
%
% Syntax
%   sVF = sVF1 .* sVF2
%   sVF = a .* sVF1
%   sVF = sVF1 .* a
%

if isnumeric(sVF1) || isa(sVF1,'S2Fun')
  sVF = sVF2;
  sVF.sF = sVF.sF.*sVF1;
elseif isnumeric(sVF2) || isa(sVF2,'S2Fun')
  sVF = sVF1;
  sVF.sF = sVF.sF.*sVF2;
end

end
