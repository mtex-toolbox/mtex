function p = paris(grains)
% Percentile Average Relative Indented Surface
%
% the paris (Percentile Average Relative Indented Surface) is shape
% parameter that measures the convexity of a grain
%
% Syntax
%   p = paris(grains)
%
% Input
%  grains - @grain2d
%
% Output
%  p - double
%
% 

% store this in local variables for speed reasons
p = zeros(size(grains));

X = grains.V(:,1);
Y = grains.V(:,2);


poly = grains.poly;
% remove inclusions
incl = grains.inclusionId;
for i = find(incl>0).'
  poly{i} = poly{i}(1:end-incl(i));
end

% compute convex hull perimeters
for id = 1:length(grains)

  % for small grains there is no difference
  if length(poly{id}) <= 7, continue; end

  % extract coordinates
  xGrain = X(poly{id});
  yGrain = Y(poly{id});

  % compute perimeter
  perimeterGrain = sum(sqrt(...
    (xGrain(1:end-1) - xGrain(2:end)).^2 + ...
    (yGrain(1:end-1) - yGrain(2:end)).^2));

  % compute convex hull
  ixy = convhull(xGrain,yGrain);

  % compute perimenter
  perimeterHull = sum(sqrt(...
    (xGrain(ixy(1:end-1)) - xGrain(ixy(2:end))).^2 + ...
    (yGrain(ixy(1:end-1)) - yGrain(ixy(2:end))).^2));

  % paris is the relative difference between convex hull perimenter and true
  % perimeter
  p(id) = 200*(perimeterGrain - perimeterHull)./perimeterHull;
  
end

