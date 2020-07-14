function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

% spread points over different centers
if numel(component.weights) == 1
  ic = ones(npoints,1);
else
  ic = discretesample(component.weights, npoints);
end
    
% take random rotational axes
axis = vector3d.rand(npoints);

% take random rotational angles
M = 1000000; % discretisation parameter

hw = min(4*component.psi.halfwidth,90*degree);
t = linspace(cos(hw),1,M);

% compute cummulative distribution function
c = 4 / pi * cumsum(sqrt(1-t.^2) .* component.psi.K(t)) / M;
c = c ./ c(end);

r = rand(npoints,1);
[~,~,id] = histcounts(r,c);
angle = 2 * acos(t(max(1,id))).';

q = quaternion(component.center(:),ic) .* axis2quat(axis,angle);

% set up orientations
ori = orientation(q,component.CS,component.SS);
