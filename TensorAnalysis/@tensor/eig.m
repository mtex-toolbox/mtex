function [V,E] = eig(T,varargin)
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


switch T.rank

  case 1
  case 2
    if all(T.isSymmetric(:))
      [V,E] = eig3(T.M,varargin{:});
    else
      E = zeros(3,length(T));
      V = zeros(3,3,length(T));
      for i = 1:length(T)
        [V(:,:,i),E(:,i)] = eig(T.M(:,:,i),'vector');
      end
    end
  case 3
  case 4
    E = zeros(6,length(T));
    V = zeros(6,6,length(T));
    M = tensor42(T.M,T.doubleConvention);
    for i = 1:length(T)
      [V(:,:,i),E(:,i)] = eig(M(:,:,i),'vector');
    end
end

if nargout <= 1
  V = E;
elseif isa(V,'double')
  V = reshape(vector3d(V(1,:),V(2,:),V(3,:),'antipodal'),3,[]);
end
