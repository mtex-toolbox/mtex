function [h,s,v] = hsl2hsv(hh,ss,ll)

h = hh;
ll = ll*2;

ind = ll <= 1;
ss(ind) = ss(ind) .* ll(ind);
ss(~ind) = ss(~ind) .* (2 - ll(~ind));

v = (ll + ss) ./ 2;
s = (2 * ss) ./ (ll + ss);
s(isnan(s)) = 0;

end

% r = linspace(1,2,30);
% omega = linspace(0,2*pi);
% [r,omega] = meshgrid(r,omega);
% x = r .* cos(omega);
% y = r .* sin(omega);
% z = zeros(size(r));
% rgb = hsv2rgb(omega./2./pi,ones(size(omega)),ones(size(omega)));
% surf(x,y,z,rgb)
% axis equal