function omega = angle_outer(q1,q2,varargin)
% calcualtes the rotational angle between all rotations q1 and q2
%
% Syntax  
%   omega = angle_outer(q1,q2)
%
% Input
%  q1, q2 - @quaternion
% 
% Output
%  omega  - double [q1 x q2]

if nargin == 1, q2 = q1; end

omega = real(2*acos(abs(dot_outer(q1,q2,varargin{:}))));
