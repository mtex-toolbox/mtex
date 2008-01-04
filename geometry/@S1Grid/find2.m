function ind = find2(S1G,x,epsilon)
% find close points
%
%% Syntax:  
% ind = find(S1G,x,epsilon) % find all points in distance epsilon
% ind = find(S1G,x)         % find closest point
%
%% Input
%  S1G     - @S1Grid
%  x       - double
%  epsilon - double
%
%% Output
%  ind - int32

if S1G(1).periodic
  p = S1G.max - S1G.min;
  y = mod(S1G.points(:)-S1G.min,p);
  x = mod(x-S1G.min,p);
else
  y = S1G.points;
  p = 0;
end

if nargin == 2
  if S1G(1).periodic
    y = [y(end)-p;y;y(1)+p];
    
    ind = binsearch(y,x)-1;
    
    ind(ind==length(y)-1) = 1;
    ind(ind==0) = length(y)-2;
  
  else
  
    ind = binsearch(y,x);
  
  end
  
else  
  ind = find_region(y,p,x,epsilon);
end
