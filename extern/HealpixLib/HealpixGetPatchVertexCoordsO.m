% Get vertex coordinates for the patch type 'O'
% [C, N, S, W, E] = HealpixGetPatchVertexCoordsO(n, i, j, INFO)
%
% Parameters
% n : grid resolution
% i : ring index
% j : intra-ring index
% INFO : intermediate information (output of HealpixSelectPatchClass())
% C : intra-patch coordinates
% P0 : (i, j) = (1, 1)
% P1 : (i, j) = (1, 2)
% P2 : (i, j) = (1, 3)
% P3 : (i, j) = (1, 4)

function [C, P0, P1, P2, P3] = HealpixGetPatchVertexCoordsO(n, i, j, INFO)

if INFO.is_south_pole == 0
    P0 = [1, 1];
    P1 = [1, 2];
    P2 = [1, 4];
    P3 = [1, 3];
else
    P0 = [4 * n - 1, 1];
    P1 = [4 * n - 1, 2];
    P2 = [4 * n - 1, 4];
    P3 = [4 * n - 1, 3];
end

int_j = fix(j);
decimal_j = j - int_j;
if int_j == 0
    int_j = 4;
end

decimal_i_n = INFO.i_n;
delta_decimal_i = decimal_i_n / 2;
delta_decimal_j = decimal_j * decimal_i_n;
offset_j = 0.5 - delta_decimal_i;

switch int_j
    case 1
        C = [0.5 - delta_decimal_i, offset_j + delta_decimal_j];
    case 2
        C = [offset_j + delta_decimal_j, 0.5 + delta_decimal_i];
    case 3
        C = [0.5 + delta_decimal_i, 1 - (offset_j + delta_decimal_j)];
    case 4
        C = [1 - (offset_j + delta_decimal_j), 0.5 - delta_decimal_i];
end

C = C - 0.5;
