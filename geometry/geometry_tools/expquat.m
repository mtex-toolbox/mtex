function q = expquat(tq,q)
% matrix exponential to convert skew symmetric matrices into quaternions
%
% Syntax
%   q = expquat(M)
%   q = expquat(T)
%   q = expquat(tq)
%   q = expquat(tq)
%   q = expquat(tq,q) % exponential map relative to quaternion q
%
% Input
%  M - skew symmetric matrix ~ element of the Lie algebra
%  T - skew symmetric rank 2 tensor
%  tq - @vector3d element of the tangential space
%  a - [a12, a13, a23] matrix entries of the skew symmetric matrix
%
% Output
%  q - @quaternion
%
% See also
% quaternion_matrix Euler axis2quat hr2quat

% for tensors extract correct matrix entries
if isa(tq,'tensor') && tq.rank == 2
  tq = reshape(vector3d(tq{6},-tq{3},tq{2}),size(tq));
  
elseif isnumeric(tq) && size(tq,1) == 3 && size(tq,2) == 3
  
  % for matrices extract correct entries
  tq = rehape(vector3d(tq(3,2,:),-tq(3,1,:),tq(2,1,:)),[],1);
      
elseif isnumeric(tq)

% generate vector3d as this will become the rotational axis
tq = vector3d(reshape(tq,[],3).').';

end

% norm of the vector is rotational angle
omega = norm(tq);
mask = omega ~=0;
tq(mask) = tq(mask) ./ omega(mask);
tq(~mask)=0*tq(~mask);

if nargin == 2
  q =  q .* quaternion(cos(omega/2),sin(omega/2).*tq);
else
  q = quaternion(cos(omega/2),sin(omega/2).*tq);
end

end
