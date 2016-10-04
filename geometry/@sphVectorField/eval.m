function f =  eval(sVF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - interpolation nodes
%
% Output
%

bario = calcBario(sVF,v);

if sVF.vec.antipodal
  
  [x,y,z] = double(sVF.vec);
  m = [x(:).*x(:),x(:).*y(:),y(:).*y(:),x(:).*z(:),y(:).*z(:),z(:).*z(:)];
  M = bario * m;
  
  xyz = zeros(length(v),3);
  for i = 1:length(v)
    MLocal = reshape(M(i,[1 2 4 2 3 5 4 5 6]),3,3);
    [xyz(i,:),~,~] = svds(MLocal,1);
  end
  
  f = vector3d(xyz.','antipodal');
  
else
  f = bario * sVF.vec(:);
end
  
  
end
