function sAF = example(varargin)
% Construct example for an S2AxisFieldHarmonic.

nodes = equispacedS2Grid('points', 1e4);
nodes = nodes(:);
y = S2Fun.smiley.grad(nodes);

sAF = S2VectorFieldTri(nodes, y);

end