function DSO3 = refine(DSO3)


% step 1: compute center of any two orientation connected by an edge

% all combinations of vertices of all tetrahegons
v1 = DSO3.tetra(:,[1 1 1 2 2 3]).';
v2 = DSO3.tetra(:,[2 3 4 3 4 4]).';

% unique edges
vv = sort([v1(:),v2(:)],2);
[v,~,iCenterEdges] = unique(vv,'rows');
iCenterEdges = length(DSO3) + reshape(iCenterEdges,6,[]).';

% step 2: set up corner tetrahegons
% bases
base = iCenterEdges(:,[1 2 3  1 4 5  2 4 6  3 5 6]);
base = reshape(base.',3,[]);
corner = reshape(DSO3.tetra.',1,[]);

% split center octaeder into four tetrahegons
octaeder = iCenterEdges(:,[1 3 4 5  3 4 5 6  1 2 3 4  2 3 4 6]);
octaeder = reshape(octaeder.',4,[]);

% set up tetraeder
newTetra = [[base;corner],octaeder].';

% new vertices as mean of all edges
centerEdges = mean2(DSO3.subSet(v(:,1)),DSO3.subSet(v(:,2)));

% set up refined grid
DSO3.a = [DSO3.a(:);centerEdges.a];
DSO3.b = [DSO3.b(:);centerEdges.b];
DSO3.c = [DSO3.c(:);centerEdges.c];
DSO3.d = [DSO3.d(:);centerEdges.d];
DSO3.i = zeros(size(DSO3.d));

% set up new tetrahegons
DSO3.tetra = sort(newTetra,2);

% compute neighbouring list
DSO3.tetraNeighbour = calcNeighbour(DSO3.tetra);

% the neighbours of the four corner tetrahegons
%1 2 3 4
%cornerNeighbour = 
%DSO3.tetraNeighbour

% set up new lookup
%DSO3.lookup = DSO3.lookup*8;
%DSO3.lookup = calcLookUp(DSO3,5*degree);
DSO3.lookup = [];
res = 40*degree;
for i = 1:3
  res = res / 2;
  DSO3.lookup = calcLookUp(DSO3,res);
end


end

% -----------------------------------------------------------------
function v = mean2(v1,v2)
% compute the mean of two orientations

dv = inv(v1) .* v2;
dv.SS = specimenSymmetry;

[dv,omega] = dv.project2FundamentalRegion;

% half angle
dv.a = dv.a .* cos(omega./4) ./ cos(omega./2);
dv.b = dv.b .* sin(omega./4) ./ sin(omega./2);
dv.c = dv.c .* sin(omega./4) ./ sin(omega./2);
dv.d = dv.d .* sin(omega./4) ./ sin(omega./2);

% new vertices
v = v1 .* dv;

end
