function v =  eval(sVF,nodes)
%
% Syntax
%   v = eval(sFV,nodes)
%
% Input
%  sFV - @S2VectorField
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
  
  v = vector3d(xyz.','antipodal');
  
else
  v = bario * sVF.values(:);
end

end
