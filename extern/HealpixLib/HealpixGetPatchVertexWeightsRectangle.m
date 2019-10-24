% Get interpolation weights for the rectangular patch
% vertexes : v1(0.5, 0.5), v2(0.5, -0.5), v3(-0.5, 0.5), v4(-0.5, -0.5)
% [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRectangle(delta_i, delta_j)
%
% Parameters
% delta_i, delta_j : position in rectangle (center is (0, 0))
% w1 : weight for v1 (NW)
% w2 : weight for v3 (NE)
% w3 : weight for v4 (SW)
% w4 : weight for v2 (SE)

function [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRectangle(delta_i, delta_j)

delta_i = delta_i + 0.5;
delta_j = delta_j + 0.5;

w4 = delta_i * delta_j;
w3 = delta_i * (1 - delta_j);
w2 = (1 - delta_i) * delta_j;
w1 = (1 - delta_i) * (1 - delta_j);
