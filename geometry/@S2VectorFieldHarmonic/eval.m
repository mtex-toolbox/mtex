function f = eval(sVF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - interpolation nodes
%
% Output
%

v = v(:);

if ( sVF.sF_n.bandwidth == 0 ) && ( sVF.sF_n.fhat(1) == 0 )
  f = sVF.sF_theta.eval(v).*S2VectorField.theta(v)+...
    max(sin(v.theta), 0.01).^-2.*sVF.sF_rho.eval(v).*S2VectorField.rho(v);
else
  f = sVF.sF_theta.eval(v).*S2VectorField.theta(v)+...
    max(sin(v.theta), 0.01).^-2.*sVF.sF_rho.eval(v).*S2VectorField.rho(v)+...
    sVF.sF_n.eval(v).*S2VectorField.n(v);
end

end
