function rot = rotation(T)
% convertes orthogonal rank 2 tensors into rotations
%
% Syntax
%   rot = rotation(T)
%
% Input
%  T - orthogonal rank 2 @tensor
%
% Output
%  rot - @rotation
%

rot = rotation.nan(length(T));

switch T.rank

  case 2
    for i = 1:length(T)
      rot(i) = mat2quat(T.M(:,:,i));   
    end
    
    rot = rot .* sign(det(T));
   
  otherwise
    error('Tensor needs to have rank 2!')
end

