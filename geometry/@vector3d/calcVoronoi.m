function [V,C] = calcVoronoi(v,varargin)
% compute the area of the Voronoi decomposition
%
% Input
%  v - @vector3d
%
% Output
%  V - list of Voronoi--Vertices
%  C - cell array of Voronoi--Vertices per generator
%
%% See also
% voronoin

n = length(v);
v = reshape(v,[],1);

[x,y,z] = double(v);
faces = convhulln([x(:) y(:) z(:)],{'Qt','Pp','QJ'}); % delauny triangulation on sphere

% voronoi-vertices
V = normalize(cross(v.subsref(faces(:,3))-v.subsref(faces(:,1)),v.subsref(faces(:,2))-v.subsref(faces(:,1))));

% voronoi-vertices around generators
[center, vertices] = sort(faces(:));


v = v.subsref(center);
vert = repmat(V,3,1);
vert = vert.subsref(vertices);

% the azimuth of a voronoi-vertex relativ to its generator
[ignore,azimuth] = polar(hr2quat(v,zvector).*cross(v,vert));

% sort the vertices clockwise around with respect to its center
[ignore,left] = sortrows([center azimuth]); %#ok<*ASGLU>

left = mod(vertices(left)'-1,length(V))+1;

% now we delete duplicated voronoi vertices
eps = 10^-10; % machine precision
[ignore,first,ind] = unique(round(squeeze(double(V))/eps)/eps,'rows');
V = V.subsref(first); 
left = ind(left)';

% erase duplicated vertices in the pointer list
dublicated = find([diff(left)==0,false]);

% check whether the duplicated is in the next cell // they shouldn't be
% deleted
last = [0;find(diff(center));length(center)];
dublicated(ismember(dublicated,last)) = [];

left(dublicated) = [];
center(dublicated) = [];

C = cell(n,1);
last = [0;find(diff(center));length(center)];
for k=1:numel(last)-1  
  ndx = last(k)+1:last(k+1);
  C{center(ndx(1))} = left( ndx );
end
