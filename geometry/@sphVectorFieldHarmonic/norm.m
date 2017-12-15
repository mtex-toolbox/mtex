function sF = norm(sVF)
% norm of the gradient on the sphere
%
% Syntax
%  norm(sVF)
%

sF = sphFunHarmonic.quadrature(@(v) norm(sVF.eval(v)));

end
