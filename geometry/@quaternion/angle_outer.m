function omega = angle_outer(q1,q2,varargin)
% calcualtes the rotational angle between all rotations q1 and q2
%
%% Syntax  
%  omega = angle_outer(q1,q2)
%
%% Input
%  q1, q2 - @quaternion
% 
%% Output
%  omega  - double [q1 x q2]

omega = 2*acos(min(1,dot_outer(q1,q2,varargin{:})));
  
