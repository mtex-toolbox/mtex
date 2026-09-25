function [a,b] = slerpWeights(th,t)
% the weights of x and y in the point at fraction t of an arc th between unit quaternions;
% a vanishing arc is its chord

s = sin(th);
a = sin((1-t) .* th) ./ s;
b = sin(t .* th) ./ s;
small = s < 1e-12;
t = t + zeros(size(th));
a(small) = 1 - t(small);
b(small) = t(small);
