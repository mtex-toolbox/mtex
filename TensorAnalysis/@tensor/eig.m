function [V,E] = eig(T)
% compute the eigenvalues and eigenvectors of a tensor
%
% Syntax
%   E = eig(T)
%   [V,E] = eig(T)
%
% Input
%  T - list of M rank 2 @tensor
%
% Output
%  E - 3xM list of eigen values
%  V - 3xM list eigen @vector3d
%

E = zeros(3,length(T));
V = zeros(3,3,length(T));
switch T.rank

  case 1
  case 2
    for i = 1:length(T)
      [V(:,:,i),E(:,i)] = eig(T.M(:,:,i),'vector');
    end
  case 3
  case 4
    error('no idea what to do!')
    M = tensor42(T.M);
    [E,V] = eig(M);
end

if nargout <= 1
  V = E;
else
  V = vector3d(squeeze(V(1,:,:)),squeeze(V(2,:,:)),squeeze(V(3,:,:)));
end
