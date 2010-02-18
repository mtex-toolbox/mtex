function r = quaternion(s,i)
% get quaternions

if nargin ==2
    r = quaternion(s.rotation(i));
else
    r = quaternion(s.rotation);
end
