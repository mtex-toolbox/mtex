function kappa = curvature(gB,n)
% curvature of a boundary segment
%
% Syntax
%   kappa = curvature(gB)
%   kappa = curvature(gB,2)
%
% Description
%
% Input
%  gB - @grainBoundary
%   n - number of neighbours that are considered
%
% Output
%  kappa - 1/fitting Radius in EBSD units
%

mp = gB.midPoint;

% adjecents matrix segments - segments
A_F = gB.A_F;

% consider only those with exactly two neighbours
has2n = (full(sum(A_F)) == 2).';

% find for each segments the two neigbouring segments
% u - is a 2n list of segment ids neighbouring 
[u,~] = find(A_F(:,has2n));

% try to reorder them nicely
u = reshape(u,2,[]).';
switchLR = u(:,2)-u(:,1)>2;
u(switchLR,:) = fliplr(u(switchLR,:)); 

% center midpoints
mpC = mp(has2n,:);

% left and right midpoints
mpL = mp(u(:,1),:);
mpR = mp(u(:,2),:);

% try to make the order compatible 
% the sign of the curvature should correlate with the order of the vertices
%distL = gB.V(gB.F(has2n,1),:) - m
%switchLR = 


% compute curvature
kappa = zeros(length(gB),1);

%K = 2*abs((x2 - x1).*(y3 - y1) - (y2 - y1).*(x3 - x1)) ./ ...
%  sqrt(((x2-x1).^2+(y2-y1).^2)*((x3-x1).^2+(y3-y1).^2)*((x3-x2).^2+(y3-y2).^2));

kappa(has2n) = 2*(((mpC - mpL) .* fliplr(mpR - mpL)) * [1;-1]) ./ ...
  sqrt(sum((mpC-mpL).^2,2) .* sum((mpR-mpL).^2,2) .* sum((mpC-mpR).^2,2));

% if not ordered nicely, take only absolute value of the curvature
if ~all(has2n) || nnz(switchLR)/length(switchLR)>0.8, kappa = abs(kappa); end

% do some smoothing to the curvature
if nargin == 1, n = 50; end

hasLeft = has2n;
hasLeft(has2n) = has2n(u(:,1));

hasRight = has2n;
hasRight(has2n) = has2n(u(:,2));

weights = 1;

for k = 1:n

  kappaR = kappa(u(hasRight(has2n),2));
  kappa(hasLeft) = kappa(hasLeft) + weights * kappa(u(hasLeft(has2n),1));
  kappa(hasRight) = kappa(hasRight) + weights * kappaR;
  kappa(has2n) = kappa(has2n) ./ (1+weights*hasLeft(has2n)+weights*hasRight(has2n));
  
end

end