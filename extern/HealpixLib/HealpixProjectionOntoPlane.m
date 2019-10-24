% HEALPix projection onto the plane
%
% [i, j] = HealpixProjectionOntoPlane(n, x, y)
%
% Parameters
% n : resolution of the grid (N_side)
% x : coordinate in plane (corresponding to azimuth)
% y : coordinate in plane (corresponding to elevation)
% i : ring index in decimal
% j : intra-ring index in decimal

function [i, j] = HealpixProjectionOntoPlane(n, x, y)

%i = 2 * n - y * 4 * n / pi;
i = 2 * n + y * 4 * n / pi;   % 0.0 <= i <= 4 * n

% clip to the valid range
if i <= 0
    i = 0;
end
if i >= 4 * n
    i = 4 * n;
end

% pole
if i < 1 || i > 4 * n - 1
    s = 1;
    n_j = 2;
elseif i < n
% north polar cap area
    s = 1;
    n_j = 2 * i;
elseif i > 3 * n
% south polar cap area
    s = 1;
    n_j = 2 * (4 * n - i);
else
% equatorial belt area
    di_d = i - n;
    di_i = fix(di_d);
    if mod(di_i, 2) == 0
        s = 1 - (di_d - di_i);
    else
        s = di_d - di_i;
    end
    n_j = 2 * n;
end

j = x * n_j / pi + s / 2;   % 0.0 < j <= 2 * n_j

% clip to the valid range
if j <= 0
    j = j + 2 * n_j;
end
if j > 2 * n_j
    j = j - 2 * n_j;
end
