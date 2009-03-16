function q = brassOrientation(cs)
% returns the cube orientation

q = Miller2quat([1 6 8],[2 1 1],cs);
