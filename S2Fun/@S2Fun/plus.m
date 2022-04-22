function sF = plus(sF1, sF2)
% overloads sF1 + sF2

if isa(sF2,'S2FunHarmonic')
  sF = sF2 + sF1;
  return
end

sF = S2FunHandle(@(v) sF1.eval(v) + sF2.eval(v));

end