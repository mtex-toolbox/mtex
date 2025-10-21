function grains = refineBoundary(grains,varargin)
% refine grain boundary
%
% Syntax
%
%   grains = refineBoundary(grains,segLength)
%
% Input
%  grains - @grain2d
%  delta  - new segment length
%
% Output
%  grains - @grain2d
%

sL = grains.boundary.segLength;

if nargin > 1 && isnumeric(varargin{1})
  delta = varargin{1};
else
  delta = median(sL) / 2;
end

% number of subdivisions
numPoint = max(0,round(sL ./ delta - 1));

F = grains.boundary.F;

% compute new vertices
lambda = arrayfun(@(x) (1:x)./(x+1),numPoint,'UniformOutput',false);
lambda = [lambda{:}].';

% the interpolation matrix
A = sparse(1:sum(numPoint),repelem(F(:,1),numPoint),lambda,sum(numPoint),numel(grains.allV)) + ...
  sparse(1:sum(numPoint),repelem(F(:,2),numPoint),1-lambda,sum(numPoint),numel(grains.allV));
newV = A * grains.allV;

allV = [grains.allV; newV];

% update F
% duplicate faces which we are going to subdivide
oldFid = repelem(1:size(F,1),numPoint+1);
F = repelem(F,numPoint+1,1);

hasAdded = arrayfun(@(x) [false,true(1,2*x),false], numPoint,'UniformOutput',false);
hasAdded = [hasAdded{:}];

F = F.';
F(hasAdded) = numel(grains.allV) + repelem(1:numel(newV),2);
F = F.';

% update boundary properties
grains.boundary.grainId = grains.boundary.grainId(oldFid,:);
grains.boundary.ebsdId = grains.boundary.ebsdId(oldFid,:);
grains.boundary.phaseId = grains.boundary.phaseId(oldFid,:);
grains.boundary.misrotation = grains.boundary.misrotation(oldFid);
grains.boundary.F = F;
grains.allV = allV;

grains.poly = calcPolygonsC(grains.boundary.I_FG,F,allV,grains.N);
