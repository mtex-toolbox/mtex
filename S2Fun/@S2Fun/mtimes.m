function sF = mtimes(sF1,sF2)
% implements |sF1 * alpha| and |alpha*sF2| as matrix product
%
% Syntax
%   sF = a * sF1
%
% Input
%  sF1, sF2 - @S2Fun
%  a - double
%
% Output
%  sF - @S2Fun
%

if isnumeric(sF1) || isnumeric(sF2)
  sF = sF1 .* sF2;
  return
end

error('Operator * is not supported for operands of this types. Use .* or conv() instead.')

end