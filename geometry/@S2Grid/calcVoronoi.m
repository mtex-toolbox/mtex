function [V,C] = calcVoronoi(S2G,varargin)
% compute the area of the Voronoi decomposition
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  V - list of Voronoi-Vertices
%  C - cell array of Voronoi-Vertices per generator
%
%% Options
% incomplete
%
%% See also
% voronoin

n = numel(S2G);
S2G = reshape(vector3d(S2G),[],1);

[x,y,z] = double(S2G);
faces = convhulln([x(:) y(:) z(:)]); % delauny triangulation on sphere

% voronoi-vertices
V = normalize(cross(S2G(faces(:,3))-S2G(faces(:,1)),S2G(faces(:,2))-S2G(faces(:,1))));

% the triangulation may have some defects, i.e. interior faces;
if check_option(varargin,'incomplete')
  del = angle(v,-zvector) > eps;
  faces = faces(del,:);
  V = V(del,:);
end

% voronoi-vertices around generators
[center vertices] = sort(faces(:));
S2G = S2G(center);
vert = repmat(V,3,1);
vert = vert(vertices);

% the azimuth of a voronoi-vertex relativ to its generator
[ignore,azimuth] = polar(hr2quat(S2G,zvector).*cross(S2G,vert));

% sort the vertices clockwise around with respect to its center
[ignore,left] = sortrows([center azimuth]);

% colDist = diff([0;find(diff(center));numel(center)]);
% C = mat2cell(mod(vertices(left)'-1,numel(V))+1,1,colDist)';

left = mod(vertices(left)'-1,numel(V))+1;

C = cell(n,1);
last = [0;find(diff(center));numel(center)];
for k=1:numel(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = left( ndx );
end
