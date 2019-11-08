% Translate Mercator projection -> HEALPix projection
% x, y : Mercator projection in Cartesian Coordinates
% ox, oy : HEALPix projection in Cartesian Coordinates

function [ox, oy] = HealpixPlanePoleDistortInv(x, y)

ox = x;
oy = y;

if pi / 4 < abs(y)
    partition = fix(2 * x / pi);
    x_t = x - partition * pi / 2;   % = mod(x, pi / 2);
    d0 = pi / 2 - abs(y);
    d1 = pi / 4;
    x_c = x_t - pi / 4;
    ox = x_c * d0 / d1 + (x - x_t + pi / 4);
end

