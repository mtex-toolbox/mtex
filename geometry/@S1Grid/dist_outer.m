function d = dist_outer(S1G,x)
% distance to all points of S1Grid

if (length(x) == 1) 
  if S1G(1).periodic
    x = mod(x-S1G(1).min,S1G(1).max-S1G(1).min)+S1G(1).min;
  end
  y =  [S1G.points];
elseif length(x) > 1
  x = mod(x-S1G(1).min,S1G(1).max-S1G(1).min)+S1G(1).min;
  x = repmat(reshape(x,1,[]),sum(GridLength(S1G)),1);
    
  y = repmat(reshape([S1G.points],[],1),1,size(x,2));  
end

d = abs(y-x);


if S1G(1).periodic
  d = min(d,S1G(1).max-S1G(1).min-d);
end
