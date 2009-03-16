function q = gossOrientation(cs)
% returns the cube orientation

q = Miller2quat([0 1 1],[1 0 0],cs);
