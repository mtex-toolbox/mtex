function sF = times(sF1,sF2)
% overloads |sF1 .* sF2|
%
% Syntax
%   sF = sF1 .* sF2
%   sF = a .* sF2
%   sF = sF1 .* a
%
% Input
%  sF1, sF2 - @S1FunHarmonic
%  a - double
%
% Output
%  sF - @S1FunHarmonic
%

if isnumeric(sF1)
  sF = sF2;
  sF.fhat = reshape(sF1,[1,size(sF1)]).*sF.fhat;
  return
end
if isnumeric(sF2)
  sF = sF2 .* sF1;
  return
end

sF = @(x) sF1.eval(x).*sF2.eval(x);
sF = S1FunHarmonic.quadrature(sF,'bandwidth', min(getMTEXpref('maxS1Bandwidth'),sF1.bandwidth + sF2.bandwidth));

end
