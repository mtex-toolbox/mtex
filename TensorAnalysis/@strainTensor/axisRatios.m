function [r12,r23,r31] = axisRatios(T)
% logarithmic axis ratios of the finite strain ellipsoid

e = eig(T);

e = flipud(e);
r12 = e(1,:) - e(2,:);
r23 = e(2,:) - e(3,:);
r31 = e(3,:) - e(1,:);
