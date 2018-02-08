function v = vector3d(T)
% convert rank one tensors to vector3d
%
% Syntax
%   v = vector3d(T)
%
% Input
%  T - rank one @tensor
%
% Output
%  v - @vector3d
%

if T.rank ~= 1
  error('Only rank one tensors can be converted into vectors')
end
  
v = vector3d(T.M(1,:),T.M(2,:),T.M(3,:));
v = reshape(v,size(T));