% Get vertex coordinates for the patch type 'T'
% [C, NW, NE, SW, SE] = HealpixGetPatchVertexCoordsT(n, i, j, INFO)
%
% Parameters
% n : grid resolution
% i : ring index
% j : intra-ring index
% INFO : intermediate information (output of HealpixSelectPatchClass())
% C : intra-patch coordinates
% NW : coordinates for north-east vertex
% NE : coordinates for north-west vertex
% SW, SE : coordinates for south vertex (always SW = SE since the patch is triangular shape)

function [C, NW, NE, SW, SE] = HealpixGetPatchVertexCoordsT(n, i, j, INFO)

int_j = fix(j);
if int_j == 0
    int_j = 4 * n;
end
east_int_j = mod(int_j + 1 - 1, 4 * INFO.int_i_n) + 1;

if INFO.is_south_pole == 0
    NW = [n, int_j];
    NE = [n, east_int_j];
    SW = [n + 1, int_j];
    SE = SW;

    decimal_i = INFO.decimal_i_n;
else
    SW = [3 * n, int_j];
    SE = [3 * n, east_int_j];
    NW = [3 * n - 1, int_j];
    NE = NW;

    decimal_i = 1 - INFO.decimal_i_n;
end

decimal_j = INFO.decimal_polar_intra_part;

if 1 > INFO.decimal_i_n
    C = [decimal_i, decimal_j / (1 - INFO.decimal_i_n)] - 0.5;
else
    C = [decimal_i, decimal_j] - 0.5;
end
