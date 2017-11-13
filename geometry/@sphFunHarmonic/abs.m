function sF = abs(sF)
% absolute value of a function

f = @(v) abs(sF.eval(v));
sF = sphFunHarmonic.quadrature(f);

end
