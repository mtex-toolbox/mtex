function [min,max,p] = getData(G)
% return maximum value

min = G(1).min;
max = G(1).max;

if G(1).periodic
  p = max-min;
else
  p = 0;
end
