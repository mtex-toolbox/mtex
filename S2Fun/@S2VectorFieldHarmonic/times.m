function sVF = times(sVF1,sVF2)
% pointwise product of a vector field with a number or a spherical function
%
% Syntax
%
%   sVF = sF .* sVF1 % vector field times a spherical function
%   sVF = a .* sVF1  % vector field times a number
%   sVF = sVF1 .* a  % the same
%

if isnumeric(sVF1) || isa(sVF1,'S2Fun')
  sVF = sVF2;
  sVF.sF = sVF.sF.*sVF1;
elseif isnumeric(sVF2) || isa(sVF2,'S2Fun')
  sVF = sVF1;
  sVF.sF = sVF.sF.*sVF2;
end

end
