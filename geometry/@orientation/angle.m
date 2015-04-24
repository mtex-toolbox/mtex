function omega = angle(o1,o2)
% calculates rotational angle between orientations
%
% Syntax  
%   omega = angle(o)
%   omega = angle(o1,o2)
%
% Input
%  o1, o2 - @orientation
% 
% Output
%  o1 x o2 - angle (double)

if nargin == 1
  
  [~,omega] = project2FundamentalRegion(o1);
  omega = reshape(omega,size(o1));
  
else
  
  omega = real(2*acos(dot(o1,o2)));
  
end
