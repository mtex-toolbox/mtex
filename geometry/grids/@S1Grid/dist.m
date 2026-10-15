function d = dist(S1G,x)
% distance to all points of S1Grid

if S1G(1).periodic
  x = mod(x-S1G(1).min,S1G(1).max-S1G(1).min)+S1G(1).min;
  d = abs([S1G.points]-x);
  d = min([d;S1G(1).max-S1G(1).min-d]);
else
  d = abs([S1G.points]-x);
end
