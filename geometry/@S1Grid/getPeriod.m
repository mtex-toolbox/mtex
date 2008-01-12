function p = getPeriod(G)
% return maximum value

if G(1).periodic
  p = G(1).max-G(1).min;
else
  p = 0;
end
