function kam = KAM(ebsd,varargin)
% intragranular average misorientation angle per orientation
%
% Syntax
%
%   plot(ebsd,ebsd.KAM ./ degree)
%
%   % ignore misorientation angles > threshold
%   kam = KAM(ebsd,'threshold',10*degree);
%   plot(ebsd,kam./degree)
%
%   % ignore grain boundary misorientations
%   [grains, ebsd.grainId] = calcGrains(ebsd)
%   plot(ebsd, ebsd.KAM./degree)
%
%   % consider also second order neighbors
%   kam = KAM(ebsd,'order',2);
%   plot(ebsd,kam./degree)
%
%   % consider all neighbors within a physical distance instead of order
%   kam = KAM(ebsd,'radius',3*dxy);
%
%   % weight neighbors by a kernel function of their physical distance
%   kam = KAM(ebsd,'order',3,'weights',@(d) exp(-(d/dxy).^2));
%
% Input
%  ebsd - @EBSD
%
% Options
%  order     - consider neighbors up to graph-distance n (default 1)
%  radius    - consider neighbors up to physical distance r, instead of order
%  threshold - ignore misorientation angles larger than threshold
%  max       - take not the mean but the maximum misorientation angle
%  weights   - function handle psi(distance) weighting each neighbor by its
%              physical distance (default: uniform weight 1)
%
% See also
% grain2d.GOS EBSD.gridIndex

nE = length(ebsd);

% lattice coordinates and 1-hop stencil - works generically for gridded
% (square/hex) and scattered/phase-subset data alike
[ij,A,stencil] = ebsd.gridIndex;

% neighbor offsets: either a graph-distance ball (order) or a
% physical-distance ball (radius)
radius = get_option(varargin,'radius',[]);
if ~isempty(radius)

  minStep = min(vecnorm(stencil*A',2,2));
  % safe (generous) hop bound covering the requested radius - the only cost
  % of overestimating is a slightly larger, still map-size independent, ball
  hops = ceil(radius / (minStep*0.5)) + 1;
  offs = neighborBall(stencil,hops);
  physDist = vecnorm(offs*A',2,2);
  keep = physDist <= radius;
  offs = offs(keep,:);
  physDist = physDist(keep);

else

  order = get_option(varargin,'order',1);
  offs = neighborBall(stencil,order);
  physDist = vecnorm(offs*A',2,2);

end

% neighbor weights
psi = get_option(varargin,'weights',[]);
if isempty(psi)
  w = ones(size(offs,1),1);
else
  w = psi(physDist);
end

isMax = check_option(varargin,'max');
if isMax
  fun = @(a,b) max(a,b);
else
  fun = @(a,b) nanplus(a,b);
end

threshold = get_option(varargin,'threshold',inf);

% fast lookup table (i,j) -> ebsd index, 0 = no such lattice node
ijMin = min(ij,[],1);
ijSize = max(ij,[],1) - ijMin + 1;
ij2slot = @(IJ) (IJ(:,1)-ijMin(1)) + (IJ(:,2)-ijMin(2))*ijSize(1) + 1;
ij2ebsd = zeros(prod(ijSize),1);
ij2ebsd(ij2slot(ij)) = 1:nE;

hasGrainId = ebsd.hasGrainId;

kam = zeros(nE,1);
count = zeros(nE,1);

for o = 1:size(offs,1)

  % look up the neighbor at this offset for every pixel in one vectorized pass
  IJn = ij + offs(o,:);
  inBox = IJn(:,1) >= ijMin(1) & IJn(:,1) <= ijMin(1)+ijSize(1)-1 & ...
          IJn(:,2) >= ijMin(2) & IJn(:,2) <= ijMin(2)+ijSize(2)-1;

  idx = zeros(nE,1);
  idx(inBox) = ij2ebsd(ij2slot(IJn(inBox,:)));

  valid = idx > 0;
  valid(valid) = ebsd.isIndexed(valid) & ebsd.isIndexed(idx(valid));

  % calculate misorientation angles per phase
  omega = nan(nE,1);
  for p = ebsd.indexedPhasesId

    use = valid;
    use(use) = ebsd.phaseId(use) == p & ebsd.phaseId(idx(use)) == p;
    if ~any(use), continue; end

    o1 = orientation(ebsd.rotations(use),ebsd.CSList(p));
    o2 = orientation(ebsd.rotations(idx(use)),ebsd.CSList(p));
    omega(use) = angle(o1,o2);

  end

  % apply angle threshold
  omega(omega > threshold) = NaN;

  % avoid grain boundaries
  if hasGrainId
    gidN = nan(nE,1);
    gidN(valid) = ebsd.grainId(idx(valid));
    omega(ebsd.grainId ~= gidN) = NaN;
  end

  kam = fun(kam, omega * w(o));
  count = fun(count, ~isnan(omega) * w(o));

end

if isMax
  kam(count==0) = NaN;
else
  kam = kam ./ count;
  kam(count==0) = NaN;
end

kam = reshape(kam,size(ebsd));

end
