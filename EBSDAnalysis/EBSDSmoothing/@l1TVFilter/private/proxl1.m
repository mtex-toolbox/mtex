function x = proxl1(x,v,lambda)
% the proximal step of lambda * d(x,v) towards the reference v, unit quaternions n x m x 4;
% where v is NaN, x stays

d = sum(x .* v,3);
v = v .* (1 - 2*(d < 0));
th = 2 * asin(min(1, sqrt(sum((x-v).^2,3)) / 2));

t = min(lambda ./ (2*th), 1);
keep = isnan(v(:,:,1));
t(keep) = 0;
th(keep) = 0;
v(keep(:,:,[1 1 1 1])) = 0;

[a,b] = slerpWeights(th,t);
x = a .* x + b .* v;
