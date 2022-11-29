function sF = uminus(sF)
% overloads |-sF|

sF = S2FunHandle(@(v) - sF.eval(v));

end