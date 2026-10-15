function bario = calcBario(DSO3,ori,tetra)
% compute bariocentric coordinates for an orientation
%
% Input
%  DSO3  -
%  ori   - @orientation
%  tetra - indices to tetrahegons
%
% Output
%  bario - bariocentric coordinates
%

% compute vertices
vertices = DSO3.subSet(DSO3.tetra(tetra,:));

% translate everything such that ori becomes the identity
vertices = repmat(inv(ori(:)),1,4) .* reshape(vertices,[],4);

% and project to fundamental region
vertices = reshape(project2FundamentalRegion(vertices),[],4);

% project to three dimensional space
xyz = vertices.Rodrigues;

% compute bariocentic coordinates
bario = calcZeroBario(xyz(:,1),xyz(:,2),xyz(:,3),xyz(:,4));

end
