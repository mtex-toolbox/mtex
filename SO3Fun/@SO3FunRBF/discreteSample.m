function ori = discreteSample(SO3F,npoints,varargin)
% draw a random sample
%

% spread points over different centers
ic = nan(npoints,numel(SO3F));
for k = 1:numel(SO3F)
  x = [full(SO3F.weights(:,k));SO3F.c0(k)];
  if sum(x)>0
    ic(:,k) = discretesample(x, npoints);
  end
end
    
ori = orientation.nan(npoints,numel(SO3F),SO3F.CS,SO3F.SS);

% the uniform random orientations
isUniform = ic == size(SO3F.weights,1)+1;
ori(isUniform) = orientation.rand(nnz(isUniform),SO3F.CS,SO3F.SS);

% the not uniform random orientations
isRBF = ic <= size(SO3F.weights,1);
if ~any(isRBF), return; end

% take random rotational axes for the remaining samples
axis = vector3d.rand(nnz(isRBF));

% random rotational angles
M = 1000000; % discretization parameter

hw = min(4*SO3F.psi.halfwidth,90*degree);
t = linspace(cos(hw),1,M);

% compute cumulative distribution function
c = 4 / pi * cumsum(sqrt(1-t.^2) .* SO3F.psi.eval(t)) / M;
c = c ./ c(end);

% random sample with respect to the CDF
r = rand(nnz(isRBF),1);
[~,id] = histc(r,c);
angle = 2 * acos(t(id)).';

% set up random orientations
ori(isRBF) = times(reshape(SO3F.center(ic(isRBF)),[],1), ...
  rotation.byAxisAngle(axis,angle),false);

% random symmetry elements
ori = ori .* SO3F.CS.rot(randi(SO3F.CS.numSym,size(ori)));
if SO3F.SS.numSym>1
  ori = SO3F.SS.rot(randi(SO3F.SS.numSym,size(ori))) .* ori;
end

if npoints == 1, ori = reshape(ori,size(SO3F)); end
