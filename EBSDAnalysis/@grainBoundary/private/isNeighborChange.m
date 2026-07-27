function isChange = isNeighborChange(gB)
% segments whose head vertex separates a different pair of grains than the
% segment following it along the same chain
%
% Syntax
%   isChange = isNeighborChange(gB)
%
% Description
% Such a vertex is a corner of both grain polygons even when only two segments
% meet there, and a coarsening step must not merge across it - the merged
% segment could only carry one of the two grainId pairs.
%
% On a full map this always coincides with a junction. On a subset it does not:
% at a triple point of grains A, B, C where only A is in the subset, the
% segment B|C is gone, so the vertex has degree two and looks like an ordinary
% point along a chain - but the segments A|B and C|A that remain there have
% different neighbours.
%
% Input
%  gB - @grainBoundary
%
% Output
%  isChange - logical, one entry per segment, true if its head must be kept
%
% See also
% grainBoundary/simplify grainBoundary/reduce

gId = sort(gB.grainId,2);

isChange = [any(diff(gId,1,1) ~= 0,2); false];

% only compare within a chain - across a chain end the head is a junction and
% is kept anyway
isChange = reshape(isChange & ~gB.isChainEnd,size(gB.F,1),1);
