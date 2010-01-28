function rot=transpose(rot)
% transpose array of orientations

rot.quaternion = rot.quaternion.';
rot.i = rot.i.';
