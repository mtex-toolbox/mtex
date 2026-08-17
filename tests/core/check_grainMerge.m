function check_grainMerge
% grain2d/merge: several criteria in one call, and option values that are
% not criteria
%
% merge collects every criterion it is given into one merge matrix and then
% takes the connected components of it. Two things have to hold for that to
% be trustworthy, and neither did:
%
% # a call with several criteria applies all of them, whatever order they
% are written in - two branches used to ASSIGN to the merge matrix instead
% of adding to it, so everything collected before them was silently thrown
% away. On the twinning example of doc/Grains/GrainMerge.m,
% merge(grains,twinBoundary,'inclusions','maxSize',5) returned 86 grains
% where the twin merge alone returns 28.
% # the value of an option is not a criterion. The dispatch classifies
% every entry of varargin by type and shape, so an n x 2 numeric value was
% read as a list of grain pairs - and on a two grain map a 2 x 2 value was
% read as an adjacency matrix. merge(grains,gB,'someOption',[5 10]) merged
% grains 5 and 10 and dropped gB.
%
% Everything here is a small synthetic map with an exactly known answer.
%
% See also
% check_calcGrainsCases

cs = crystalSymmetry('1','mineral','test');

%% a map with two things to merge: a weak stripe boundary and an inclusion
%
% left half and right half are ten degrees apart, and the left half carries
% a 2x2 speck of a completely different orientation, which is an inclusion
% below any sensible minimum size.

n = 24;
rot = rotation.id(n,n);
rot(:,1:12) = orientation.id(cs);
rot(:,13:24) = orientation.byAxisAngle(zvector,10*degree,cs);
rot(11:12,5:6) = orientation.byAxisAngle(zvector,40*degree,cs);

ebsd = EBSDsquare([],rot,2*ones(n,n),[0 1],{'notIndexed',cs},'dxy',[1 1]);
grains = calcGrains(ebsd,'threshold',5*degree,'minPixel',1);

if length(grains) ~= 3 || nnz(grains.isInclusion) ~= 1
  error(['grainMerge: expected two halves and one inclusion, got %d grains ' ...
    'and %d inclusions'],length(grains),nnz(grains.isInclusion));
end

gB = grains.boundary;
stripeBoundary = gB(all(ismember(gB.grainId,grains.id(~grains.isInclusion)),2) & ...
  diff(gB.grainId,1,2) ~= 0);

if isempty(stripeBoundary)
  error('grainMerge: the two halves should share a boundary');
end

%% each criterion on its own
if length(merge(grains,stripeBoundary)) ~= 2
  error('grainMerge: the boundary alone should join the two halves');
end

if length(merge(grains,'inclusions','maxSize',5)) ~= 2
  error('grainMerge: the inclusion alone should be absorbed into its host');
end

%% both criteria in one call, in either order
%
% This is the regression: with the assignment the second of the two used to
% erase the first, so the answer depended on the order of the arguments.

nFirst = length(merge(grains,stripeBoundary,'inclusions','maxSize',5));
nSecond = length(merge(grains,'inclusions','maxSize',5,stripeBoundary));

if nFirst ~= 1 || nSecond ~= 1
  error(['grainMerge: two criteria in one call must both be applied, ' ...
    'expected 1 grain, got %d with the boundary first and %d with the ' ...
    'inclusions first'],nFirst,nSecond);
end

%% the value of an option is not a list of grain pairs
%
% 'someOption' is not an option merge knows - a typo, or one forwarded by a
% wrapper. Its value must be ignored, not acted on.

nPlain = length(merge(grains,stripeBoundary));
nWithValue = length(merge(grains,stripeBoundary,'someOption',[1 3]));

if nWithValue ~= nPlain
  error(['grainMerge: the value of an unknown option was taken for a list ' ...
    'of grain pairs - %d grains instead of %d'],nWithValue,nPlain);
end

% the same for a value that has the shape of an adjacency matrix, which on
% a small map it easily does
twoGrains = merge(grains,'inclusions','maxSize',5);
M = ones(length(twoGrains));

if length(merge(twoGrains,'someOption',M)) ~= length(twoGrains)
  error(['grainMerge: the value of an unknown option was taken for an ' ...
    'adjacency matrix']);
end

%% a pair list given as an argument still works
%
% The guard above must not break the documented form merge(grains,gid).

ids = grains.id(~grains.isInclusion);

if length(merge(grains,ids(:).')) ~= 2
  error('grainMerge: a list of grain id pairs given as an argument must still merge');
end

% and an empty list is not an error
if length(merge(grains,zeros(0,2))) ~= length(grains)
  error('grainMerge: an empty pair list must merge nothing');
end

end
