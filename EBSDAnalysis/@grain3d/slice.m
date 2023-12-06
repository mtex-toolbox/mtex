function slice(grains,plane)
% plane         - plane in matGeom Format
% myGrain - 
% V             - n x 3 array with allVertices
% poly          - n x 1 cell array
% E             - Edges with respect indices of V
% FE            - cell array of faces with respect to indices of E
% crossingEdges - indices of Edges crossing the plane
% crossingFaces - indices of Faces crossing the plane
% crossingFE    - array j x 2 with only the Edges to be
%   intersected, j with respect to crossingFaces, Edges with respect to E
% newV          - crossingEdges intersected with plane @vector3d
% newPoly       - intersected Polygon, indices to newV
%%

plane = createPlane([0.5 0.5 0.5],[1 1 1]);

assert(isPlane(plane),'Input is not a plane in matGeom-Format')

myGrain = grains(3);
V = myGrain.boundary.allV.xyz;
poly = myGrain.poly;

E = meshEdges(poly);
% evtl noch Edges mit vorn und hinten selben Punkt entfernen
FE = meshFaceEdges(V, E, poly);

crossingEdges = find(xor(isBelowPlane(V(E(:,1),:),plane),isBelowPlane(V(E(:,2),:),plane)));
crossingFE = cell2mat(cellfun((@(el) ismember(crossingEdges,el)'), FE, 'UniformOutput', false));
crossingFaces = find(sum(crossingFE,2)==2);

% crossingFE: 1.dim with respect to crossingFaces, 2.dim with respect to
% crossingEdges
[i,j] = find(crossingFE);
[~,i2] = sort(i);
crossingFE = reshape(j(i2),2,[])';

newV = vector3d(intersectEdgePlane([V(E(crossingEdges,1),:) V(E(crossingEdges,2),:)],plane));

newPoly = {crossingFE(1,:)};
nextEdge = crossingFE(1,2);
crossingFE(1,2) = 0;

for n = 1:size(crossingFE,1)-1
[i,j] = find(crossingFE==nextEdge);
assert(length(i)==1)
% abs(j-3) so 1=>2 and 2=>1
nextEdge = crossingFE(i,abs(j-3));
crossingFE(i,:) = [0 0];
newPoly = {[newPoly{1} nextEdge]};
end

plot(grains2d)
hold on
drawPolygon3d(newV(newPoly{1}).xyz)

%grain2d(newV, newPoly, myGrain.meanOrientation, myGrain.CSList, myGrain.phaseId, myGrain.phaseMap)




