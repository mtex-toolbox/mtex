function sF = plus(sF1,sF2)
% overloads |sF1 + sF2|
%
% Syntax
%   sF = sF1 + sF2
%   sF = a + sF1
%   sF = sF1 + a
%
% Input
%  sF1, sF2 - @S1Fun
%  a - double
%
% Output
%  sF - @S1Fun
%

if isnumeric(sF1)
  sF = sF2+sF1;
  return
end
if isnumeric(sF2)
  sF = S1FunHandle(@(o) sF1.eval(o) + sF2);
  return
end
sF = S1FunHandle(@(o) sF1.eval(o) + sF2.eval(o));
  
end