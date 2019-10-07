% [theta, phi] = HealpixNorthernHemisphere(n, i, j)
% Parameters
% n : resolution of the grid (N_side)
% i : ring index
% j : pixel in ring index

function [theta, phi] = HealpixNorthernHemisphere(n, i, j)

% North polar cap
if i < n
    theta = acos(1 - i^2 / (3 * n^2));
    phi = pi * (j - 0.5) / (2 * i);
else    
% North equatorial belt
    theta = acos(4 / 3 - 2 * i / (3 * n));
    s = mod(i - n + 1, 2);
    phi = pi * (j - s / 2) / (2 * n);
end
