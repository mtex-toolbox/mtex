function dir = calcMeanDirection(gB,n)
% compute a smoothed direction that ignores staircasing 
%
% Syntax
%   dir = calcMeanDirection(gB)
%   dir = calcMeanDirection(gB,2)
%
% Description
% This is very similar to direction with the only difference that it takes
% the average over 2*n+1 directions
%
% Input
%  gB - @grainBoundary
%
% Output
%  dir - @vector3d
%


if nargin == 1, n = 1; end

% adjecents matrix vertices - vertices
I_VF = gB.I_VF; %#ok<*PROP>
A_V = I_VF * I_VF.';

% find for each vertex the neigbouring vertices
[u,v] = find(A_V^n);

% X, Y values of the neighbouring vertices
X = sparse(u,v,gB.V(v,1),size(A_V,1),size(A_V,1));
Y = sparse(u,v,gB.V(v,2),size(A_V,1),size(A_V,1));

% take the mean
X = full(sum(X,2)) ./ sum(A_V ~= 0,2);
Y = full(sum(Y,2)) ./ sum(A_V ~= 0,2);

% compute the direction
dir = normalize(vector3d(X(gB.F(:,1)) - X(gB.F(:,2)),...
  Y(gB.F(:,1)) - Y(gB.F(:,2)), zeros(length(gB),1),'antipodal'));
      
end