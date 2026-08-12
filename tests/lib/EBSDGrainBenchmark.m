function ebsd = EBSDGrainBenchmark(colAngles,rowAngles,varargin)
% synthetic square-grid EBSD map with a grid of grains and exactly
% prescribed boundary misorientation angles, for benchmarking noise-robust
% grain reconstruction
%
% The grains are laid out as a (numel(rowAngles)+1) x (numel(colAngles)+1)
% array of square blocks. Grain orientations follow the product structure
%
%   ori(i,j) = u_i * v_j
%
% where u_i is a chain of rotations realizing rowAngles and v_j a chain
% realizing colAngles. This makes every boundary angle exact:
%
%   horizontal neighbours: (u_i v_j)^-1 (u_i v_{j+1}) = v_j^-1 v_{j+1}
%                          -> colAngles(j)
%   vertical neighbours:   (u_i v_j)^-1 (u_{i+1} v_j) = v_j^-1 (u_i^-1 u_{i+1}) v_j
%                          -> a conjugate, hence the SAME angle rowAngles(i)
%
% and it is automatically consistent around every 4-cycle of grains, which
% freely chosen pairwise misorientations would not be.
%
% NOTE: this exactness relies on the disorientation being attained at the
% identity symmetry element, i.e. it holds only while all prescribed angles
% stay well below the smallest rotation of the crystal symmetry group (60
% degree for cubic). At 50-70 degree the conjugate no longer preserves the
% symmetry-reduced angle. This benchmark is meant for the low-angle regime.
%
% With 'deformation' > 0 the prescribed angles remain exact for the grain
% MEAN orientations, while the local misorientation observed across a
% boundary varies along it, because each grain carries its own orientation
% ramp.
%
% Syntax
%   ebsd = EBSDGrainBenchmark(colAngles,rowAngles)
%   ebsd = EBSDGrainBenchmark(colAngles,rowAngles,'grainSize',50,...
%            'noiseLevel',1.5*degree,'deformation',5*degree)
%
%   % predefined difficulty levels, see below
%   ebsd = EBSDGrainBenchmark('level',1)
%
% Input
%  colAngles - misorientation angles (rad) across the vertical boundaries,
%              i.e. between consecutive grain columns
%  rowAngles - misorientation angles (rad) across the horizontal
%              boundaries, i.e. between consecutive grain rows
%
% Options
%  grainSize         - grain width/height in pixels (default: 50)
%  stepSize          - EBSD step size (default: 1)
%  noiseLevel        - maxAngle (rad) of per pixel orientation noise, drawn
%                      via orientation.rand (default: 0)
%  deformation       - total intra grain orientation spread (rad) of a
%                      linear orientation gradient with random in plane
%                      direction and random rotation axis per grain
%                      (default: 0)
%  roughness         - std (pixels) of the random displacement applied to
%                      each boundary line (default: 0)
%  wildFraction      - fraction of pixels replaced by a uniformly random
%                      orientation, simulating mis indexed pixels
%                      (default: 0)
%  unindexedFraction - fraction of pixels marked notIndexed (default: 0)
%  CS                - crystalSymmetry (default: crystalSymmetry('cubic'))
%  seed              - rng seed, for reproducible benchmarks
%  level             - 1, 2 or 3, see below. Overrides all of the above and
%                      may be given instead of colAngles/rowAngles.
%
% Difficulty levels
%  1 'clean'    noise only, no deformation, no outliers
%  2 'noisy'    + wild pixels, notIndexed pixels, rough boundaries
%  3 'deformed' + a 5 degree linear orientation gradient per grain
%
% Output
%  ebsd - @EBSDsquare
%
%  ebsd.prop.trueGrainId - ground truth grain index (1..numGrains) per
%    pixel, for EVERY pixel including wild and notIndexed ones: it is the
%    grain the pixel geometrically belongs to. Grain row i and grain column
%    j have the index i + (j-1)*numGrainRows, i.e. the linear index into
%    the numGrainRows x numGrainCols array opt.trueMeanOrientation.
%  ebsd.prop.isWild        - mis indexed pixels
%  ebsd.prop.isUnindexed   - notIndexed pixels
%  ebsd.opt                - colAngles, rowAngles, grainSize, numGrainRows,
%    numGrainCols and trueMeanOrientation, used by scoreGrainBenchmark
%
% See also
%  scoreGrainBenchmark calcGrains

% ---------------------------------------------------------------- presets

if nargin >= 1 && (ischar(colAngles) || isstring(colAngles))
  varargin = [{colAngles} varargin]; % 'level' passed as first argument
  if nargin >= 2 && isnumeric(rowAngles)
    varargin = [varargin(1) {rowAngles} varargin(2:end)];
  end
  colAngles = []; rowAngles = [];
end

level = get_option(varargin,'level',[]);
if ~isempty(level)
  [colAngles,rowAngles,preset] = benchmarkLevel(level);
  % find_option takes the LAST occurrence, so the preset goes first and any
  % explicitly passed option overrides it
  varargin = [preset varargin];
end

if isempty(colAngles), colAngles = (1:7)*degree; end
if nargin < 2 || isempty(rowAngles), rowAngles = [2 4 6]*degree; end

% ------------------------------------------------------------------ input

if check_option(varargin,'seed'), rng(get_option(varargin,'seed')); end

grainSize   = get_option(varargin,'grainSize',50);
stepSize    = get_option(varargin,'stepSize',1);
noiseLevel  = get_option(varargin,'noiseLevel',0);
deformation = get_option(varargin,'deformation',0);
roughness   = get_option(varargin,'roughness',0);
wildFrac    = get_option(varargin,'wildFraction',0);
unindFrac   = get_option(varargin,'unindexedFraction',0);
CS          = get_option(varargin,'CS',crystalSymmetry('cubic'));

colAngles = colAngles(:).';
rowAngles = rowAngles(:).';

nGC = numel(colAngles) + 1;   % number of grain columns
nGR = numel(rowAngles) + 1;   % number of grain rows
nP  = nGR * nGC;              % number of grains

nRows = nGR * grainSize;      % map size in pixels
nCols = nGC * grainSize;

% ------------------------------------------- ground truth grain partition
%
% Grain columns are separated by vertical boundary lines whose position may
% depend on the pixel row, grain rows by horizontal boundary lines whose
% position may depend on the pixel column. Both stay monotone as long as
% the displacement is small compared to grainSize, so the grains remain
% connected blocks and the partition remains a valid tiling.

maxShift = max(0,grainSize/2 - 1);

grainCol = ones(nRows,nCols);
for j = 1:nGC-1
  d = smoothRandomLine(nRows,roughness,grainSize/4,maxShift);
  grainCol = grainCol + ((1:nCols) > (j*grainSize + d(:)));
end

grainRow = ones(nRows,nCols);
for i = 1:nGR-1
  d = smoothRandomLine(nCols,roughness,grainSize/4,maxShift);
  grainRow = grainRow + ((1:nRows).' > (i*grainSize + d));
end

% grain (i,j) gets the MATLAB linear index of an nGR x nGC array, so that
% opt.trueMeanOrientation(trueGrainId) is the orientation of that grain
trueGrainId = grainRow + (grainCol - 1)*nGR;

% ------------------------------------------------- grain mean orientations

u = rotation.id(nGR,1);
for i = 1:nGR-1
  u(i+1) = u(i) * rotation.byAxisAngle(vector3d.rand,rowAngles(i));
end

v = rotation.id(nGC,1);
for j = 1:nGC-1
  v(j+1) = v(j) * rotation.byAxisAngle(vector3d.rand,colAngles(j));
end

oriGrain = rotation.id(nGR,nGC);
for i = 1:nGR
  for j = 1:nGC
    oriGrain(i,j) = u(i) * v(j);
  end
end

rot = oriGrain(trueGrainId);

% ------------------------------------------------- linear orientation ramp

if deformation > 0

  [px,py] = meshgrid(1:nCols,1:nRows);
  px = px(:); py = py(:); gid = trueGrainId(:);

  % random in plane gradient direction and rotation axis per grain
  phi   = 2*pi*rand(nP,1);
  gAxis = vector3d.rand(nP,1);

  % coordinate along the grain's own gradient direction
  cx = accumarray(gid,px,[nP 1],@mean);
  cy = accumarray(gid,py,[nP 1],@mean);
  s  = (px - cx(gid)).*cos(phi(gid)) + (py - cy(gid)).*sin(phi(gid));

  % normalise so that max - min equals exactly 'deformation' per grain
  sRange = accumarray(gid,s,[nP 1],@(x) max(x)-min(x));
  sRange(sRange <= 0) = 1;
  s = s ./ sRange(gid);

  rot = rot(:) .* rotation.byAxisAngle(gAxis(gid),deformation*s);
  rot = reshape(rot,nRows,nCols);
end

% ------------------------------------------------------------------ noise

if noiseLevel > 0
  rot = rot .* orientation.rand(size(rot),CS,'maxAngle',noiseLevel);
end

% ------------------------------------------------------------- outliers

nPix     = nRows*nCols;
isWild   = false(nPix,1);
isUnind  = false(nPix,1);

if wildFrac > 0
  idx = randperm(nPix,round(wildFrac*nPix));
  isWild(idx) = true;
  rot(idx) = orientation.rand(numel(idx),1,CS);
end

if unindFrac > 0
  cand = find(~isWild);
  idx  = cand(randperm(numel(cand),round(unindFrac*nPix)));
  isUnind(idx) = true;
end

% --------------------------------------------------------------- assemble
%
% phase 1 is notIndexed, phase 2 carries CS - the standard MTEX convention,
% used unconditionally so that the phase layout does not depend on whether
% unindexedFraction is zero.

phaseId = 2*ones(nPix,1);
phaseId(isUnind) = 1;

ebsd = EBSDsquare([],rot,phaseId,[0 1],{'notIndexed',CS}, ...
  'dxy',[stepSize stepSize]);

ebsd.prop.trueGrainId = trueGrainId(:);
ebsd.prop.isWild      = isWild;
ebsd.prop.isUnindexed = isUnind;

ebsd.opt.colAngles           = colAngles;
ebsd.opt.rowAngles           = rowAngles;
ebsd.opt.grainSize           = grainSize;
ebsd.opt.numGrainRows        = nGR;
ebsd.opt.numGrainCols        = nGC;
ebsd.opt.deformation         = deformation;
ebsd.opt.noiseLevel          = noiseLevel;
ebsd.opt.trueMeanOrientation = orientation(oriGrain,CS);

end

% -------------------------------------------------------------- helpers

function d = smoothRandomLine(n,amp,corrLen,maxShift)
% smooth random displacement of a boundary line, std = amp pixels

d = zeros(1,n);
if amp <= 0, return; end

corrLen = max(1,corrLen);
k = exp(-0.5*((-ceil(3*corrLen):ceil(3*corrLen))/corrLen).^2);
k = k / sum(k);

d = conv(randn(1,n),k,'same');
if std(d) > 0, d = d / std(d) * amp; end

d = max(min(d,maxShift),-maxShift);

end

function [colAngles,rowAngles,opts] = benchmarkLevel(level)
% the three fixed difficulty levels, each with its own fixed seed

if ischar(level) || isstring(level)
  level = find(strcmpi(level,{'clean','noisy','deformed'}));
end

colAngles = (1:7)*degree;
rowAngles = [2 4 6]*degree;

switch level
  case 1
    opts = {'seed',0,'grainSize',50,'noiseLevel',1.5*degree};
  case 2
    opts = {'seed',1,'grainSize',50,'noiseLevel',1.5*degree, ...
      'wildFraction',0.02,'unindexedFraction',0.05,'roughness',3};
  case 3
    opts = {'seed',2,'grainSize',50,'noiseLevel',1.5*degree, ...
      'wildFraction',0.02,'unindexedFraction',0.05,'roughness',3, ...
      'deformation',5*degree};
  otherwise
    error('level must be 1, 2 or 3 (clean, noisy, deformed)');
end

end
