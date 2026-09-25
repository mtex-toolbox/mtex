function [xOut,yOut] = proxTV(xIn,yIn,lambda)
% the proximal step of lambda * d(x,y) for pairs of unit quaternions, n x m x 4: both move
% along their arc by the fraction t, x from its end and y from the other

% the representative of y nearest x, and the arc between them, half the rotation angle
d = sum(xIn .* yIn,3);
yIn = yIn .* (1 - 2*(d < 0));
th = 2 * asin(min(1, sqrt(sum((xIn-yIn).^2,3)) / 2));

t = min(lambda ./ (2*th), 0.5);
[a,b] = slerpWeights(th,t);
xOut = a .* xIn + b .* yIn;
yOut = b .* xIn + a .* yIn;
