function rDSO3 = refine(DSO3)


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
centerEdges = mean2(DSO3.subsref(v(:,1)),DSO3.subsref(v(:,2)));

rDSO3 = DelaunaySO3([orientation(DSO3);centerEdges],'tetra',newTetra);

end

% -----------------------------------------------------------------
function v = mean2(v1,v2)
% compute the mean of two orientations

dv = inv(v1) .* v2;
dv.SS = symmetry;

[dv,omega] = dv.project2FundamentalRegion;

% half angle
dv.a = dv.a .* cos(omega./2) ./ cos(omega./4);
dv.b = dv.b .* sin(omega./2) ./ sin(omega./4);
dv.c = dv.c .* sin(omega./2) ./ sin(omega./4);
dv.d = dv.d .* sin(omega./2) ./ sin(omega./4);

% new vertices
v = v1 .* dv;

end
