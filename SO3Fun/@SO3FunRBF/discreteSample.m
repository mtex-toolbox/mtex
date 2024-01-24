function ori = discreteSample(SO3F,npoints,varargin)
% draw a random sample
%

% spread points over different centers
ic = discretesample([SO3F.weights(:);SO3F.c0], npoints).';
    
isUniform = ic == length(SO3F.weights)+1;

% some uniform random orientations
ori = orientation.rand(length(ic),SO3F.CS,SO3F.SS);

% the remaining points
npoints = nnz(~isUniform);
if npoints == 0, return; end

% take random rotational axes for the remaining samples
axis = vector3d.rand(npoints);

% random rotational angles
M = 1000000; % discretisation parameter

hw = min(4*SO3F.psi.halfwidth,90*degree);
t = linspace(cos(hw),1,M);

% compute cummulative distribution function
c = 4 / pi * cumsum(sqrt(1-t.^2) .* SO3F.psi.eval(t)) / M;
c = c ./ c(end);

% random sample with respect to the CDF
r = rand(npoints,1);
[~,id] = histc(r,c);
angle = 2 * acos(t(id)).';

% set up random orientations
ori(~isUniform) = times(reshape(SO3F.center(ic(~isUniform)),[],1), ...
  rotation.byAxisAngle(axis,angle),false);

% random symmetry elements
ori = ori .* SO3F.CS.rot(randi(SO3F.CS.numSym,length(ori),1));
if SO3F.SS.numSym>1
  ori = SO3F.SS.rot(randi(SO3F.SS.numSym,length(ori),1)) .* ori;
end