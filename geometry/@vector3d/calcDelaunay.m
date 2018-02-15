function [face,vertices,v] = calcDelaunay(v)
% compute the Delaynay triangulation for a spherical grid
%
% Input
%  v - @vector3d
%
% Output
%  face     -
%  vertices - 

% shifts vectors a little bit to prevent bad thinks
v = reshape(v,[],1) + 0.001*vector3d.rand(length(v));
v = v ./ norm(v);

% compute convex hull
xyz = squeeze(shiftdim(double(v),1));

face = convhulln(xyz')';
face = flipud(face);

% rotate each column so smallest entry is first.
for j = 1 : size(face,2)
  if ( face(2,j) < face(1,j) && face(2,j) < face(3,j) )
    face(:,j) = [ face(2,j), face(3,j), face(1,j) ]';
  elseif ( face(3,j) < face(1,j) && face(3,j) < face(2,j) )
    face(:,j) = [ face(3,j), face(1,j), face(2,j) ]';
  end
end

%  Sort the columns lexically.
face = sortrows(face')';

% compute vertices
vertices = cross(v.subSet(face(2,:))-v.subSet(face(1,:)),v.subSet(face(3,:))-v.subSet(face(1,:)));

% normalize
vertices =  vertices ./ norm(vertices);
