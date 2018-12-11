function [g_phi1,g_Phi,g_phi2] = grad_phi(odf,ori)
% discrete derivatives with respect to Euler angles

[phi1,Phi,phi2] = Euler(ori,'nfft');

delta = 0.05 * degree;
ori = orientation.byEuler(phi1 + [-1 1] * delta,Phi,phi2,ori.CS,'nfft');

g_phi1 = diff(odf.eval(ori))/delta/2;

ori = orientation.byEuler(phi1,Phi + [-1 1] * delta,phi2,ori.CS,'nfft');

g_Phi = diff(odf.eval(ori))/delta/2;

ori = orientation.byEuler(phi1,Phi,phi2 + [-1 1] * delta,ori.CS,'nfft');

g_phi2 = diff(odf.eval(ori))/delta/2;
