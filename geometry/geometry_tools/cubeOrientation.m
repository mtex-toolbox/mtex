function q = cubeOrientation(cs)
% returns the cube orientation

q = Miller2quat([0 0 1],[1 0 0],cs);
