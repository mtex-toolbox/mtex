function [grainsContour] = boundaryContours(grains)
% Redraw grain boundary segments using a contouring algorithm instead of
% following pixel edges
%
% This is similar to the marching squares contour solution but enables the
% number of vertices and segments to be preserved.
% new gB segment vertices are positioned halfway between the original segment
% midpoint its adjacent segment midpoints.
%
%
% Input
%  grains - @grain2d - grains output from calcGrains
%
% Output
%  grainsContour - @grain2d with updated grain vertices grains.allV
%
% Versions
% 2024-07-23 - Created function, tested on mtexdata twins
% 2024-07-24 - remove for-loops, tested output is still the same
% 2025-03-14 - compatiblity with MTEX 6.2.beta.3 -- switch V = gB.V to gB.allV

gB = grains.boundary;
V = gB.allV; %initialise V variable as copy of old - this will get updated
midPoints = gB.midPoint;

x = true(gB.length,1);
% find gB neighbour segments - attached to either end of the current segment
% count number of segments adjacent to each segment
numNeighbours = sum(gB.A_F,2); % A_F is symmetric, doesn't matter whether you sum rows or columns
% (checked with neighbours1 = sum(gB.A_F,1);)

% if it's not a 'nice' boundary segment with two neighbour segments
% it's probably a map edge or triple junction or quad point
% ignore this point
x(numNeighbours~=2)= false;

% find the positions of these neighbours
%neihgoburs should end up as a cell array of lenght of num segments
% neighbours=cell(gB.length,1);
[n1,nIx,~] = find(gB.A_F); %nix is in sorted order, n1 is not
neighbours = mat2cell(n1,groupcounts(nIx));

VIds = gB.F(x,:); %vertices of segment X
vOld = gB.allV(VIds); %vertex positions for segment x

%define new vertices as halfway between current and neighbour midpoints
% but we don't know which vertex the segment starts/ends at
% so try both (vNew1 vs vNew2)
vNew1 = (midPoints(permute(cat(2,neighbours{x}),[2 1])) + midPoints(x)) /2 ;
% reorder the segments
vNew2 = flip(vNew1,2);
% decide which way to update V based on minimum distance to the
% original
% i.e. don't reassign  the segments backwards
vDist1 = sum(norm(vNew1-vOld),2); %these are always positive or 0
vDist2 = sum(norm(vNew2-vOld),2);

% assign new vertices
vNew = vector3d.nan(size(vNew1)); %initialise vNew
vNew((vDist1 < vDist2),:) = vNew1((vDist1 < vDist2),:);
vNew((vDist2 < vDist1),:) = vNew2((vDist2 < vDist1),:);
if any(vDist2 == vDist1)
    %unexpected output. assign to a random one and warn user
    warning('looks like vNew1 and vNew2 are equidistant to vOld? check V reassignment');
    vNew((vDist2 == vDist1),:) = vNew1((vDist2 == vDist1),:);
end

% % now update gB.allV with vNew
V(VIds) = vNew; %some things get updated more than once but maybe this is ok


grainsContour = grains;
grainsContour.allV = V;
