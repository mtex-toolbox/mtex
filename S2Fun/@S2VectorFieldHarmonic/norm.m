function sF = norm(sVF)
% norm of the gradient on the sphere
%
% Syntax
%  norm(sVF)
%

sF = S2FunHarmonic.quadrature(@(v) norm(sVF.eval(v)));

end
