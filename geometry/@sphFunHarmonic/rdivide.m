function sF = rdivide(sF1, sF2)
%
% Syntax
%  sF = sF1/sF2
%  sF = sF1/a
%  sF = a/sF1
%

if isnumeric(sF1)
	f = @(v) sF1./sF2.eval(v);
	sF = sphFunHarmonic.quadrature(f, 'm', 2*sF2.M);
elseif isnumeric(sF2)
	sF = sF1;
	sF.fhat = sF.fhat./sF2;
else
	f = @(v) sF1.eval(v)./sF2.eval(v);
	sF = sphFunHarmonic.quadrature(f, 'm', 2*max(sF1.M, sF2.M));
end

end
