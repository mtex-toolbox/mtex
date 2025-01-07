function sF = rdivide(sF1, sF2)
% overloads ./
%
% Syntax
%   sF = sF1 ./ sF2
%   sF = sF1 ./ a
%   sF = a ./ sF2
%
% Input
%  sF1, sF2 - @S1Fun
%  a - double
%
% Output
%  sF - @S1Fun
%

if isnumeric(sF1)
  sF = S1FunHandle(@(o) sF1./ sF2.eval(o));
  return
end

sF = times(sF1,1./sF2);

end

