function sF = uminus(sF)
% overloads |-sF|

sF = S1FunHandle(@(o) -sF.eval(o));

end