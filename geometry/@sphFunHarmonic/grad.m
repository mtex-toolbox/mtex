function [sF_theta, sF_rho] = grad(sF) % gradient

sF_theta = sF.dtheta;
sF_rho = sF.drho;

end
