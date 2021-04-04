function ori = discreteSample(SO3F,npoints,varargin)
% draw a random sample
%

% spread points over different centers
ic = discretesample([SO3F.weights;SO3F.c0], npoints).';
    
isUniform = ic == length(SO3F.weights)+1;

% some uniform random orientations
ori = orientation.rand(length(ic),SO3F.CS,SO3F.SS);

% take random rotational axes for the remaining samples
npoints = nnz(~isUniform);
axis = vector3d.rand(npoints);

% random rotational angles
M = 1000000; % discretisation parameter

hw = min(4*SO3F.psi.halfwidth,90*degree);
t = linspace(cos(hw),1,M);

% compute cummulative distribution function
c = 4 / pi * cumsum(sqrt(1-t.^2) .* SO3F.psi.K(t)) / M;
c = c ./ c(end);

% random sample with respect to the CDF
r = rand(npoints,1);
[~,id] = histc(r,c);
angle = 2 * acos(t(id)).';

% set up random orientations
ori(~isUniform) = times(SO3F.center(ic(~isUniform)), rotation.byAxisAngle(axis,angle),false);


