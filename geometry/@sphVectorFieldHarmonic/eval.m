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

if ( sVF.sF_n.M == 0 ) && ( sVF.sF_n.fhat(1) == 0 )
  f = sVF.sF_theta.eval(v).*sphVectorField.theta(v)+...
    max(sin(v.theta), 0.01).^-2.*sVF.sF_rho.eval(v).*sphVectorField.rho(v);
else
  f = sVF.sF_theta.eval(v).*sphVectorField.theta(v)+...
    max(sin(v.theta), 0.01).^-2.*sVF.sF_rho.eval(v).*sphVectorField.rho(v)+...
    sVF.sF_n.eval(v).*sphVectorField.n(v);
end

end
