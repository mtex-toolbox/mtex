% HealpixBorderLine for the polar cap area
function P = HealpixBorderLinePC(n, k, interval, start_phi, end_phi, flag)

delta_phi = interval;
phi = start_phi - delta_phi;

P = [];
while phi < end_phi
    [phi, theta, dTheta_dPhi] = HealpixBorderGetNextPC(n, k, phi, delta_phi, flag);
    P = [P; theta phi];
    % distance in the tangent plane on the unit sphere
    dL_dPhi = sqrt(dTheta_dPhi^2 + sin(theta)^2);
    % decide the next sampling point so that each distance between the points becomes same
    delta_phi = interval / dL_dPhi;
    if phi + delta_phi > end_phi
        delta_phi = end_phi - phi;  % add the end edge point
    end
end
