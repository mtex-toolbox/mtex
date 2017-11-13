function sF = rdivide(sF1, sF2)

warning('not implemented yet');
if isnumeric(sF1)
	f = @(v) sF1./sF2.eval(v);
	sF = sphFunHarmonic.quadrature(f);

elseif isnumeric(sF2)
	sF = sF1;
	sF.fhat = sF.fhat./sF2;

else
	f = @(v) sF1.eval(v)./sF2.eval(v);
	sF = sphFunHarmonic.quadrature(f);

end

end
