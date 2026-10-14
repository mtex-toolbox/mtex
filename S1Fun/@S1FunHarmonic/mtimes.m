function sF = mtimes(sF1, sF2)
% multiply a function on the circle by a scalar or a matrix
%
% Syntax
%
%   sF = a * sF1       % multiply by the number a
%   sF = sF1 * [1;1]   % the matrix product of a vector valued function with a matrix
%
% Input
%  sF1 - @S1FunHarmonic
%  a   - double
%
% Output
%  sF - @S1FunHarmonic
%
% See also
% S1FunHarmonic/times S1FunHarmonic/conv

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
