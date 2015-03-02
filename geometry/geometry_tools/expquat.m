function q = expquat(a12,a13,a23)
% matrix exponential to convert skew symmetric matrices into quaternions
%
% Syntax
%   q = expquat(mat)
%
% Input
%  a12,a13,a23 - the matrix entries of the skew symmetric matrix
%
% Output
%  q - @quaternion
%
% See also
%
% quaternion_matrix Euler axis2quat hr2quat
%
% Description

mat = zeros(3,3,numel(a12));

% TODO: make this faster
for i = 1:numel(a12)
  skewmat = [[0 a12(i) a13(i)];[-a12(i) 0 a23(i)];[-a13(i) -a23(i) 0]];  
  mat(:,:,i) = expm(skewmat);  
end

q = mat2quat(mat);