function sVF = grad(sF) % gradient

sF_theta = sF.dtheta;
sF_rho = sF.drho;

x = @(v) cos(v.theta).*cos(v.rho).*sF_theta.eval(v)-sin(v.theta).*sin(v.rho).*sF_rho.eval(v);
y = @(v) cos(v.theta).*sin(v.rho).*sF_theta.eval(v)+sin(v.theta).*cos(v.rho).*sF_rho.eval(v);
z = @(v) -sin(v.theta).*sF_theta.eval(v);

sF_x = sphFunHarmonic.quadrature(x);
sF_y = sphFunHarmonic.quadrature(y);
sF_z = sphFunHarmonic.quadrature(z);

sVF = sphVectorFieldHarmonic(sF_x, sF_y, sF_z);

end
