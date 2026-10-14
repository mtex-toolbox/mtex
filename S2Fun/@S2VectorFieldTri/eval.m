function v =  eval(sVF,nodes)
% evaluate a spherical vector field given on a triangulation
%
% The values at the vertices are interpolated linearly by barycentric
% coordinates; for an antipodal field the axis is the leading eigenvector of
% the interpolated outer products.
%
% Syntax
%
%   v = eval(sVF,nodes)   % the field at the directions nodes
%
% Input
%  sVF   - @S2VectorFieldTri
%  nodes - interpolation nodes @vector3d
%
% Output
%  v - @vector3d
%

bario = calcBario(sVF.tri,nodes);

if sVF.values.antipodal
  
  [x,y,z] = double(sVF.values);
  m = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
  M = bario * m;
  
  xyz = zeros(length(nodes),3);
  for i = 1:length(nodes)
    MLocal = reshape(M(i,[1 2 4 2 3 5 4 5 6]),3,3);
    [xyz(i,:),~,~] = svds(MLocal,1);
  end
  
  v = vector3d.byXYZ(xyz,'antipodal');
  
else
  v = bario * sVF.values(:);
end

end
