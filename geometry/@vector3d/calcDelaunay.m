function [face,vertices,v] = calcDelaunay(v)
% compute the Delaynay triangulation for a spherical grid
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  face     -
%  vertices - 

% shifts vectors a little bit to prevent bad thinks
v = v(:) + 0.001*vector3d('random','points',length(v));
v = v ./ norm(v);


% compute convex hull
xyz = squeeze(shiftdim(double(v),1));

face = convhulln(xyz')';
face = flipud(face);
 
  
%  Rotate each column so smallest entry is first.
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
vertices = cross(v(face(2,:))-v(face(1,:)),v(face(3,:))-v(face(1,:)));

% normalize
vertices =  vertices ./ norm(vertices);
