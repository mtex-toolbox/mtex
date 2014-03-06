function [face,vertices,S2G] = calcDelaunay(S2G)
% compute the Delaynay triangulation for a spherical grid
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  face     -
%  vertices - 

% shifts vectors a little bit to prevent bad thinks
S2G.vector3d = S2G.vector3d(:) + 0.001*vector3d(S2Grid('random','points',numel(S2G)));
S2G = S2G ./ norm(S2G);


% compute convex hull
xyz = squeeze(shiftdim(double(S2G(:)),1));

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
vertices = cross(S2G.vector3d(face(2,:))-S2G.vector3d(face(1,:)),...
  S2G.vector3d(face(3,:))-S2G.vector3d(face(1,:)));

% normalize
vertices =  vertices ./ norm(vertices);
