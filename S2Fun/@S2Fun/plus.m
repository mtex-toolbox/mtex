function sF = plus(sF1, sF2)
% overloads sF1 + sF2

if isa(sF2,'S2FunHarmonic')
  sF = sF2 + sF1;
  return
elseif isa(sF2, 'S2FunMLS')
  sF = sF2 + sF1;
  return;
end

if isnumeric(sF1)
  sF = S2FunHandle(@(v) sF1 + sF2.eval(v),sF2.frame);
elseif isnumeric(sF2)
  sF = S2FunHandle(@(v) sF1.eval(v) + sF2,sF1.frame);
else
  % the sum is symmetric only under what both summands share
  sF = S2FunHandle(@(v) sF1.eval(v) + sF2.eval(v), ...
    S2Fun.jointFrame(sF1,sF2,sF1.frame));
end

end