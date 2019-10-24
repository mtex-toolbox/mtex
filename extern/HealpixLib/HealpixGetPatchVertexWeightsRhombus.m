% Get interpolation weights for the rhombus patch
% vertexes : v1(0, -1), v2(0.5, 0), v3(0, 1), v4(-0.5, 0)
% [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRhombus(delta_i, delta_j)
%
% Parameters
% delta_i, delta_j : position in rhombus (center is (0, 0))
% w1 : weight for v1 (north)
% w2 : weight for v3 (south
% w3 : weight for v4 (west)
% w4 : weight for v2 (east)

function [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRhombus(delta_i, delta_j)

% Let v1(0, -1), v2(0.5, 0), v3(0, 1), v4(-0.5, 0)
sn = [delta_i, delta_j] * [ 2; 1] / sqrt(5);	% v1->v2 ベクトル成分
so = [delta_i, delta_j] * [-1; 2] / sqrt(5);	% v1->v2 ベクトルに直行なベクトル成分

h0 = sqrt(5) / 5 - so;  % v1を含む平行四辺形のv1-v2を底辺とした際の高さ
h1 = sqrt(5) / 5 + so;  % v4を含む平行四辺形のv3-v4を底辺とした際の高さ

% (delta_i, delta_j)を通りv2-v3に平行な直線とv1-v2の交点を求める
px = (2 * delta_j + delta_i + 1) / 4;
py = -2 * px - 1;
% (px, py)とv1の長さ
q = sqrt(px^2 + (py + 1)^2);

b0 = q;                 % v1を含む平行四辺形の底辺(v1-v2軸に沿う長さ)
b1 = sqrt(5/4) - b0;    % v2を含む平行四辺形の底辺(v1-v2軸に沿う長さ)

% north
w1 = b1 * h1;   % v3を含む平行四辺形の面積

% south
w2 = b0 * h0;   % v1を含む平行四辺形の面積

% west
w3 = b1 * h0;   % v2を含む平行四辺形の面積

% east
w4 = b0 * h1;   % v4を含む平行四辺形の面積
