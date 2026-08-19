function gB = repairBoundarySense(gB,id)
% turn a stored boundary the right way round
%
% Description
% Boundary segments carry their walk direction in the column order of
% |gB.F|, and the convention is that |gB.grainId(:,1)| lies to the left of
% it. Files written before segments were stored in walk order have an
% arbitrary column order instead, so the convention holds for some of their
% grains and not for others - |data/testgrains.mat| had 14 of its 43 chains
% the wrong way round, which is enough to give two identical convex grains
% opposite curvature signs.
%
% <grainBoundary.order.html |order|> cannot repair that on its own: without
% a |leftPos| it deliberately takes the sense from the column order of |F|,
% which is the very thing that is wrong. But the sense is recoverable from
% the geometry alone. Walked with the grain on the left, the boundary of a
% grain runs counterclockwise around it, so the signed area it encloses is
% positive. A grain that comes out negative has all of its segments the
% wrong way round.
%
% Input
%  gB - @grainBoundary
%  id - ids of the grains that actually exist
%
% Output
%  gB - @grainBoundary
%
% See also
% grainBoundary/order grainBoundary/flip

if isempty(gB), return; end

% twice the signed area contribution of a segment, taken in the plane the
% grains live in rather than in xy, so that a section through a 3d dataset
% is judged by its own normal
V1 = gB.allV(gB.F(:,1));
V2 = gB.allV(gB.F(:,2));
c = dot(cross(V1,V2),normalize(gB.N));

% every grain claims the segments it borders, oriented so that it comes
% first - the second column has to be walked backwards to put its grain on
% the left, hence the minus
[gId,~,pos] = unique(gB.grainId(:));
A = accumarray(pos,[c;-c],[numel(gId) 1]);

% Only grains that are still in the list get a vote. testgrains references
% four grains that were dropped before it was saved, and the sum over such
% a phantom mixes chains that disagree, so its sign means nothing.
% A grain of zero enclosed area - the sum cannot say which way round it is -
% abstains rather than voting itself wrong
verdict = zeros(numel(gId),1);
isReal = ismember(gId,id) & gId > 0;
verdict(isReal) = -sign(A(isReal));

% a segment follows its two grains; they agree unless the file contradicts
% itself, and then the majority decides and a tie changes nothing
s = verdict(pos);
wrong = sum(reshape(s,[],2),2) > 0;

if ~any(wrong), return; end

% reverse the walk direction *without* touching grainId - flip would move
% both and preserve the convention rather than restore it. order then reads
% the corrected column order back out and rebuilds the walk from it.
gB.F(wrong,:) = fliplr(gB.F(wrong,:));
gB = gB.order;

end
