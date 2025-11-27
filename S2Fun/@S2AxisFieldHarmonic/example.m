function sAF = example(varargin)
% Construct example for an S2AxisFieldHarmonic.

nodes = equispacedS2Grid('points', 1e4);
nodes = nodes(:);
y = vector3d(sin(5*nodes.x), 1, nodes.y, 'antipodal');

sAF = S2AxisFieldHarmonic.interpolate(nodes, y);

end