function sF = plus(sF1, sF2)
% overloads sF1 + sF2

if isa(sF2,'S2FunHarmonic')
  sF = sF2 + sF1;
  return
end

if isnumeric(sF1)
  sF = S2FunHandle(@(v) sF1 + sF2.eval(v),sF2.s);
elseif isnumeric(sF2)
  sF = S2FunHandle(@(v) sF1.eval(v) + sF2,sF1.s);
else
  sF = S2FunHandle(@(v) sF1.eval(v) + sF2.eval(v),sF1.s);
end

end