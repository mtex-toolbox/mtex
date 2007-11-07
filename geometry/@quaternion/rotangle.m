function w = rotangle(q)
% rotational angle of the quaternion

w = 2*acos(min(1,abs(q.a)));
