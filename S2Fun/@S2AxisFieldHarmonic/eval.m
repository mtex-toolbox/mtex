function f = eval(sVF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - @vector3d interpolation nodes
%
% Output
%   f - @vector3d
%

xyz = zeros(length(v),3);
M = sVF.sF.eval(v);
for i = 1:length(v)
  MLocal = reshape(M(i,[1 2 4 2 3 5 4 5 6]),3,3);
  [xyz(i,:),~,~] = svds(MLocal,1);
end
f = vector3d(xyz.','antipodal');

end
