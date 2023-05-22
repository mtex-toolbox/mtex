function omega = angle(q1,q2,varargin)
% calculates the rotational angle between rotations q1 and q2
%
% Syntax  
%   omega = angle(q)
%   omega = angle(q1,q2)
%
% Input
%  q1, q2 - @quaternion
% 
% Output
%  omega  - double

if nargin >= 2
  
  if isa(q2,'quaternion')
    omega = 2*real(acos(abs(dot(q1,q2))));
  else
    omega = angle(q2,q1,varargin{:});
  end
  
else

  omega = 2*real(acos(abs(q1.a)));
  
end
