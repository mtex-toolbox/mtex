function ebsd = EBSDGrainRowBenchmark(angles,varargin)
% synthetic square-grid EBSD map: a row of grains separated by boundaries
% with prescribed misorientation angles, for benchmarking noise-robust
% grain reconstruction
%
% Syntax
%   ebsd = EBSDGrainRowBenchmark(angles)
%   ebsd = EBSDGrainRowBenchmark(angles,'grainSize',30,'noiseLevel',0.5*degree)
%
% Input
%  angles - vector of misorientation angles (rad) between consecutive
%           grains; numGrains = numel(angles)+1. Boundary axes are drawn
%           independently at random.
%
% Options
%  grainSize  - grain width/height in pixels (default: 20)
%  stepSize   - EBSD step size (default: 1)
%  noiseLevel - maxAngle (rad) of per-pixel orientation noise, drawn via
%               orientation.rand (default: 0, i.e. no noise)
%  CS         - crystalSymmetry (default: crystalSymmetry('cubic'))
%  seed       - rng seed, for reproducible benchmarks (default: not set,
%               i.e. current global rng state is used)
%
% Output
%  ebsd - EBSD object, grainSize x (numGrains*grainSize) pixels, single
%         phase, laid out as numGrains square blocks in a row.
%         ebsd.prop.trueGrainId gives the ground-truth grain index
%         (1..numGrains) per pixel, for scoring calcGrains against.
%
% See also
%  calcGrains check_calcGrainsCases

if check_option(varargin,'seed')
  rng(get_option(varargin,'seed'));
end

grainSize  = get_option(varargin,'grainSize',20);
stepSize   = get_option(varargin,'stepSize',1);
noiseLevel = get_option(varargin,'noiseLevel',0);
CS         = get_option(varargin,'CS',crystalSymmetry('cubic'));

numGrains = numel(angles) + 1;

% chain of grain orientations: prescribed angle, random axis per boundary
ori = orientation.id(CS);
for k = 1:numel(angles)
  ori(k+1) = ori(k) * rotation.byAxisAngle(vector3d.rand,angles(k)); %#ok<AGROW>
end

% lay out numGrains square blocks of grainSize x grainSize pixels in a row
n = numGrains*grainSize;

rot = rotation.id(grainSize,n);
trueGrainId = zeros(grainSize,n);
for k = 1:numGrains
  cols = (k-1)*grainSize + (1:grainSize);
  rot(:,cols) = ori(k);
  trueGrainId(:,cols) = k;
end

ebsd = EBSDsquare([],rot,ones(size(rot)),1,{CS},'dxy',[stepSize stepSize]);

if noiseLevel > 0
  ebsd.rotations = ebsd.rotations .* orientation.rand(size(ebsd),CS,'maxAngle',noiseLevel);
end

ebsd.prop.trueGrainId = trueGrainId(:);

end


function test
ebsd = EBSDGrainRowBenchmark([1,2,3,4,5,6]*degree,'grainSize',50,'noiseLevel',1.5*degree);
grains = calcGrains(ebsd,'angle',2*degree);
grains2 = calcGrains(ebsd,'angle',2*degree,'completeBoundaries');
plot(ebsd,ebsd.orientations.angle)
hold on, plot(grains2.boundary,'linewidth',2,'linecolor','w');plot(grains2.innerBoundary,'linewidth',2,'linecolor','w'); hold off
hold on, plot(grains.boundary,'linewidth',2);plot(grains.innerBoundary,'linewidth',2); hold off
end