function keepEnd = keepGrainPolygons(gB,keepEnd)
% do not coarsen a grain out of existence
%
% Syntax
%   keepEnd = keepGrainPolygons(gB,keepEnd)
%
% Description
% A grain polygon needs three distinct vertices to enclose any area, and a
% grain smaller than the tolerance loses all of them. On a single pixel grain
% the boundary is two open chains of two segments each, and straightening both
% leaves the same diagonal twice - a polygon of zero area, which then breaks
% area, centroid and plot downstream.
%
% Rather than pick which vertex to give back, a grain that would end up that
% way is left uncoarsened. The tolerance is a statement about how far the
% boundary may move, not a licence to delete a grain.
%
% This reasons about grains, so it does nothing for an inner boundary, where
% the same grain sits on both sides of every segment - the closed chain guards
% in simplify and reduce cover that case instead.
%
% Input
%  gB      - @grainBoundary
%  keepEnd - logical, one entry per segment, true if its head survives
%
% Output
%  keepEnd - the same, with the segments of the endangered grains restored
%
% See also
% grainBoundary/simplify grainBoundary/reduce

gId = gB.grainId;

% count a grain once per adjacent segment, and skip the segments that have the
% same grain on both sides
isG = gId > 0 & gId(:,[2 1]) ~= gId;
if ~any(isG(:)), return; end

nG = max(gId(:));
kk = [keepEnd keepEnd];

nKeep = accumarray(gId(isG),kk(isG),[nG 1]);
nTotal = accumarray(gId(isG),1,[nG 1]);

% a grain that had fewer than three segments to start with cannot be helped
isShort = nKeep < 3 & nTotal >= 3;
if ~any(isShort), return; end

% restoring every vertex of a short grain can only raise the counts, so one
% pass is enough
keepEnd = keepEnd | any(isShort(max(gId,1)) & isG,2);
