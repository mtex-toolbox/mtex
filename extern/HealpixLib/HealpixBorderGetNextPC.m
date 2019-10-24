% HealpixBorderGetNext for the north polar cap area
% flag = 0 : where dTheta_dPhi >= 0
% flag = 1 : where dTheta_dPhi <= 0
function [phi, theta, dTheta_dPhi] = HealpixBorderGetNextPC(n, k, prev_phi, delta_phi, flag)

phi = prev_phi + delta_phi;
a = 1;
b = - k^2 * pi^2 / (12 * n^2);

if flag == 0
    theta = acos(a + b / phi^2);
    dTheta_dPhi = 2 * b / (phi^3* sin(theta)); 
else
    theta = acos(a + b / (phi - pi/2)^2);
    dTheta_dPhi = 2 * b / ((phi - pi/2)^3 * sin(theta)); 
end
