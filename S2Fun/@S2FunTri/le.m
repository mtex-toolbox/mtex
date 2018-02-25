function sF1 = le(sF1,sF2)
% overloads sF1 <= sF2
%
% Syntax
%   sF = sF1 <= sF2
%   sF = a <= sF1
%   sF = sF1 <= a
%
% Input
%  sF1, sF2 - S2FunTri
%  a - double
%
% Output
%  sF - S2FunTri
%

% ensure first argument is S2FunTri
if ~isa(sF1,'S2FunTri'), [sF1,sF2] = deal(-sF2,-sF2); end

if isnumeric(sF2)
  sF1.values = sF1.values <= sF2;
else
  sF1.values = sF1.values <= sF2.values;
end

end