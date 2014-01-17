function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

% spread points over different centers
if numel(component.weights) == 1
  ic = ones(npoints,1);
else
  ic = discretesample(component.weights, points);
end
    
% take random rotational axes
axis = randv(npoints,1);

% take random rotational angles
M = 1000000;             % discretisation parameter
t = linspace(0,1,M);

% compute cummulative distribution function
c = 4 / pi * cumsum(sqrt(1-t.^2) .* component.psi.K(t)) / M;
  
r = rand(N,1);
[~,t] = histc(r,c);
angle = 2 * acos(t ./ M);

% set up orientations
ori = orientation(quaternion(component.center,ic) .* ...
  axis2quat(axis,angle),component.CS,component.SS);
