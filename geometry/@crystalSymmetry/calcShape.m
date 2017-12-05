function S = calcShape(cs,N)
%
% Input
%  cs - @crystalSymmetry
%  N  - face normals 
%
% Output
%  S - patch structure
%

if nargin < 2
  N = basicHKL(cs);
  N = N .* N.dspacing;
else
  N = unique(N.symmetrise,'noSymmetry');
end

% ensure N is vector3d
N = vector3d(N);
tol = 1e-5;

% compute vertices as intersections between all combinations
% of three planes
[a,b,c] = allTriple(1:length(N));
V = planeIntersect(N(a),N(b),N(c));

% take only the finite ones
V = V(V.isfinite);

% take only those inside the polyhedron
V = V(all(dot_outer(V,N) <= 1 + tol,2));
V = unique(V);

% convert to double
N = squeeze(double(N(:)));

% triangulation
DT = delaunayTriangulation(squeeze(double(V)));
[FBtri,V] = freeBoundary(DT);
TR = triangulation(FBtri,V);
FE = featureEdges(TR,1e-5)';

% preallocate face list
F = nan(length(N),length(N));

% for all potential faces
for a = 1:length(N)
  
  % which vertices belong to face a ?
  B = find(V * N(a,:).' > 1-tol).';
    
  % which featureEdges belong to face a ?
  A = FE(:,all(ismember(FE,B)));
  
  % conect edges to form a polygon
  face = cell2mat(EulerCycles(A.'));
  F(a,1:length(face)) = face;

end

% write into a patch structure
S.Vertices = V;
S.Faces = F;
if ~isempty(cs.color)
  S.FaceColor = cs.color;
else
  S.FaceColor = 'cyan';
end
S.EdgeColor = 'black';

end

% some testing code
function test

cs = loadCIF('quartz');

m = Miller({1,0,-1,0},cs);  % hexagonal prism
r = Miller({1,0,-1,1},cs);  % positive rhomboedron, usally bigger then z
z = Miller({0,1,-1,1},cs);  % negative rhomboedron
s1 = Miller({2,-1,-1,1},cs);% left tridiagonal bipyramid
s2 = Miller({1,1,-2,1},cs); % right tridiagonal bipyramid
x1 = Miller({6,-1,-5,1},cs);% left positive Trapezohedron
x2 = Miller({5,1,-6,1},cs); % right positive Trapezohedron 

% select faces to plot
N = [4*m,2*r,1.8*z,1.4*s1,0.6*x1];

S = cs.calcShape(N);

clf; patch(S); axis equal

end