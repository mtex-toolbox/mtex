function [K,E] = ellip2ke(m)
% extends Matlab ellipke function to negative arguments

mu = m;
ind = m<0;
mu(ind) = m(ind)./(m(ind)-1);
[K,E] = ellipke(mu);
K(ind) = K(ind) ./ sqrt(1 - m(ind));
E(ind) = E(ind) .* sqrt(1 - m(ind));