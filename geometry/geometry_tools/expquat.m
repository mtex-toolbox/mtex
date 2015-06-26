function q = expquat(tq,q)
% matrix exponential to convert skew symmetric matrices into quaternions
%
% Syntax
%   q = expquat(tq,q)
%   q = expquat(tq)
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


if isnumeric(tq), tq = vector3d(reshape(tq,[],3).').'; end

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
