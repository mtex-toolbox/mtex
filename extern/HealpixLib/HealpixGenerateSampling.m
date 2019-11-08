% Generate sampling points on HEALPix
%
% OUT = HealpixGenerateSampling(n, mode)
% Parameters
% n : resolution of the grid (N_side)
% mode = 'rindex' : two-dimensional ring index
%      = 'scoord' : spherical coordinates

function OUT = HealpixGenerateSampling(n, mode)

n_total = 12 * n^2;

OUT = zeros(n_total, 2);
for pn = 1:n_total
    OUT(pn, :) = HealpixNestedIndex(n, pn - 1);
end

if mode == 'rindex'
    OUT = uint16(OUT);
    return
end

for pn = 1:n_total
    i = OUT(pn, 1);
    j = OUT(pn, 2);
    [theta, phi] = HealpixGetSphCoord(n, i, j);   
    OUT(pn, :) = [theta phi];
end
