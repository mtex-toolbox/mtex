function sF = abs(sF)
% absolute value of a function

f = @(v) abs(eval(sF, v));
sF = sphFunHarmonic.quadrature(f);

end
