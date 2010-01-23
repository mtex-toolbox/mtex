function r = quaternion(s,i)
% get quaternions

if nargin ==2
    r = s.quaternion(i);
else
    r = s.quaternion;
end
