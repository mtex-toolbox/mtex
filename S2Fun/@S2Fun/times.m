function sF = times(sF1,sF2)
% overloads |sF1 .* sF2|
%
% Syntax
%   sF = sF1 .* sF2
%   sF = a .* sF2
%   sF = sF1 .* a
%
% Input
%  sF1, sF2 - @S2Fun
%  a - double
%
% Output
%  sF - @S2Fun
%

if isnumeric(sF1)
  sF = S2FunHandle(@(v) sF1 .* sF2.eval(v));
  return
end

if isnumeric(sF2)
  sF = sF2 .* sF1;
  return
end

if isa(sF2,'S2FunHarmonic')
  sF = sF2 .* sF1;
  return
end

sF = S2FunHandle(@(v) sF1.eval(v) .* sF2.eval(v));

end