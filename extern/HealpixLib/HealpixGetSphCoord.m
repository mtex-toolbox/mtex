function [theta, phi] = HealpixGetSphCoord(n, i, j)

if i <= 2 * n
    % Northern Hemisphere
    [theta, phi] = HealpixNorthernHemisphere(n, i, j);
else
    % Southern Hemisphere
    [theta, phi] = HealpixNorthernHemisphere(n, 4 * n - i, j);  % mirror symmetry of the north
    theta = pi - theta;
end
