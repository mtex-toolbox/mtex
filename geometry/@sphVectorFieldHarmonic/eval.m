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

xi_theta = vector3d(cos(v.rho).*cos(v.theta), sin(v.rho).*cos(v.theta), -sin(v.theta));
xi_rho = vector3d(-sin(v.rho).*sin(v.theta), cos(v.rho).*sin(v.theta), 0);
if sVF.n == 0
	f = max(sin(v.theta), 0.01).^-1.*sVF.theta.eval(v).*xi_theta+...
		max(sin(v.theta), 0.01).^-2.*sVF.rho.eval(v).*xi_rho;
else
	f = max(sin(v.theta), 0.01).^-1.*sVF.theta.eval(v).*xi_theta+...
		max(sin(v.theta), 0.01).^-2.*sVF.rho.eval(v).*xi_rho+...
		sVF.n.eval(v).*v;
end

end
