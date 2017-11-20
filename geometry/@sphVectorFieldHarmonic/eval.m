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

if sVF.n == 0
	xi_theta = vector3d('polar', pi/2+v.theta, v.rho);
	xi_rho = vector3d('polar', pi/2, v.rho+pi/2);
	f = sVF.theta.eval(v).*xi_theta+...
		sin(v.theta).^2.*sVF.rho.eval(v).*xi_rho;
else
	xi_theta = vector3d('polar', pi/2+v.theta, v.rho);
	xi_rho = vector3d('polar', pi/2, v.rho+pi/2);
	f = sVF.theta.eval(v).*xi_theta+...
		sin(v.theta).^2.*sVF.rho.eval(v).*xi_rho+...
		sVF.n.eval(v).*v;
end

end
