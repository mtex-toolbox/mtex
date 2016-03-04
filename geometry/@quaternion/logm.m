function T = logm(q,u)
% the dislocation tensor for a rotation
%
% Syntax
%   T = logm(q) % skew symmetric tensor for rotation q
%   T = logm(q,q_ref) % tangential tensor at q_ref
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% expquat 

tq = log(q);

M = zeros([3,3,size(q)]);

M(2,1,:) =  tq.z;
M(3,1,:) = -tq.y;
M(3,2,:) =  tq.x;

M(1,2,:) = -tq.z;
M(1,3,:) =  tq.y;
M(2,3,:) = -tq.x;

T = tensor(M,'rank',2);

if nargin == 2
  warning('check this is working!!')
  T = rotate(T,u);
end