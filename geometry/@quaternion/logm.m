function T = logm(q,varargin)
% the logarithmic map that translates a rotation into a spin tensor
%
% Syntax
%   T = logm(q) % spin tensor with reference to the identical rotation
%   T = logm(q,q_ref) % spin tensor with reference q_ref
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  T - @spinTensor
%
% See also
% spinTensor/exp 

tq = log(q,varargin{:});

M = zeros([3,3,size(q)]);

M(2,1,:) =  tq.z;
M(3,1,:) = -tq.y;
M(3,2,:) =  tq.x;

M(1,2,:) = -tq.z;
M(1,3,:) =  tq.y;
M(2,3,:) = -tq.x;

% make it a spinTensor
T = spinTensor(M);
