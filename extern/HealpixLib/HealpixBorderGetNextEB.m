% HealpixBorderGetNext for the equatorial belt area
function [phi, theta, dTheta_dPhi] = HealpixBorderGetNextEB(n, k, prev_phi, prev_theta, delta_phi, delta_theta)

phi = prev_phi + delta_phi;
a = 2 / 3 - 4 * k / (3 * n);
b = 8 / (3 * pi);
theta0 = acos(a + b * phi);
theta1 = acos(a - b * phi);

exp_theta = prev_theta + delta_theta;
if abs(theta0 - exp_theta) < abs(theta1 - exp_theta)
    theta = theta0;
    dTheta_dPhi = - b / sin(theta); 
else
    theta = theta1;
    dTheta_dPhi = + b / sin(theta); 
end
