function r=transpose(r)
% transpose array of rotations

r = transpose@quaternion(r);
r.i = r.i.';
