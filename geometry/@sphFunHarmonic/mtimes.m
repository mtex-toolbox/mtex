function sF = mtimes(sF1, sF2)

if isnumeric(sF1)
	sF = sF2;
	sF.fhat = sF.fhat*sF1;

elseif isnumeric(sF2)
	sF = sF1;
	sF.fhat = sF.fhat*sF2;

else
	f = @(v) sF1.eval(v).*sF2.eval(v);
	sF = sphFunHarmonic.quadrature(f);

end

end
