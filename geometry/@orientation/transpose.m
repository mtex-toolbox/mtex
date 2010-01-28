function o=transpose(o)
% transpose array of orientations

o.quaternion = o.quaternion.';
o.i = o.i.';
