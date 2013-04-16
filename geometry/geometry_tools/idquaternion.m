function q = idquaternion(s)
% the identical rotation - quaternion(1,0,0,0)

if nargin == 0

  q = quaternion(1,0,0,0);
  
else
  
  q = quaternion(ones(s),zeros(s),zeros(s),zeros(s));
  
end
