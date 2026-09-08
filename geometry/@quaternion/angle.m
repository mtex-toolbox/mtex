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
    % the chord |q1 -+ q2| = 2 sin(omega/4), accurate where acos of the dot is not
    d = dot(q1,q2,'noAntipodal');
    s = 1 - 2*(d < 0);
    h = sqrt((q1.a - s.*q2.a).^2 + (q1.b - s.*q2.b).^2 + ...
      (q1.c - s.*q2.c).^2 + (q1.d - s.*q2.d).^2);
    omega = 4*asin(min(h/2,1));
    % a proper and an improper rotation are a half turn apart
    omega(d == 0) = pi;
  else
    omega = angle(q2,q1,varargin{:});
  end
  
else

  omega = 2*atan2(sqrt(q1.b.^2 + q1.c.^2 + q1.d.^2),abs(q1.a));
  
end
