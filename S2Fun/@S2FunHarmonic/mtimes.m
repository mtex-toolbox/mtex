function sF = mtimes(sF1, sF2)
% multiply a spherical harmonic expansion by a scalar or a matrix
%
% Syntax
%
%   sF = a * sF1       % multiply by the number a
%   sF = sF1 * [1;1]   % a vector valued function times a matrix
%
% Input
%  sF1 - @S2FunHarmonic
%  a   - double
%
% Output
%  sF - @S2FunHarmonic
%
% See also
% S2FunHarmonic/times S2FunHarmonic/conv

if isnumeric(sF1)
  sF = sF2;
  sF.fhat = sF1 * sF.fhat;
elseif isnumeric(sF2)
  sF = sF1;
  sF2 = reshape(sF2,[1 1 size(sF2)]);
  sF.fhat = sum(sF.fhat .* sF2,3);
  s = size(sF.fhat);
  sF.fhat = reshape(sF.fhat,s(1),s(2),[]);
else
  error('not implemented yet; use .* or conv() instead');
end

end
