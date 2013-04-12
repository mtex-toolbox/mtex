function [h,s,v] = hsl2hsv(hh,ss,ll)

h = hh;
ll = ll*2;

ind = ll <= 1;
ss(ind) = ss(ind) .* ll(ind);
ss(~ind) = ss(~ind) .* (2 - ll(~ind));

v = (ll + ss) ./ 2;
s = (2 * ss) ./ (ll + ss);

end

