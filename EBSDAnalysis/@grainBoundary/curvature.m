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
has2n = full(sum(A_F)) == 2;

% find for each segments the two neigbouring segments
% u - is a 2n list of segment ids neighbouring 
[u,~] = find(A_F(:,has2n));

% center midpoints
mpC = mp(has2n,:);

% left and right midpoints
mpL = mp(u(1:2:end),:);
mpR = mp(u(2:2:end),:);

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
      
end