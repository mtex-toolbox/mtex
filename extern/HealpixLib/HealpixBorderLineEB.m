% HealpixBorderLine for the equatorial belt area
function P = HealpixBorderLineEB(n, k, interval, start_phi, end_phi, start_theta)

delta_phi = interval;
phi = start_phi - delta_phi;
delta_theta = interval;
theta = start_theta - delta_theta;

P = [];
while phi < end_phi
    [phi, theta, dTheta_dPhi] = HealpixBorderGetNextEB(n, k, phi, theta, delta_phi, delta_theta);
    P = [P; theta phi];
    % distance in the tangent plane on the unit sphere
    dL_dPhi = sqrt(dTheta_dPhi^2 + sin(theta)^2);
    % decide the next sampling point so that each distance between the points becomes same
    delta_phi = interval / dL_dPhi;
    delta_theta = dTheta_dPhi * delta_phi;
    if phi + delta_phi > end_phi
        delta_phi = end_phi - phi;  % add the end edge point
    end
end
