function r = quaternion(s,i)
% get quaternions

if nargin ==2
    r = s.quat(i);
else
    r = s.quat;
end
