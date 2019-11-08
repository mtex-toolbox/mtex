% Get vertex coordinates for the patch type 'R'
% [C, NW, NE, SW, SE] = HealpixGetPatchVertexCoordsR(n, i, j, INFO)
%
% Parameters
% n : grid resolution
% i : ring index
% j : intra-ring index
% INFO : intermediate information (output of HealpixSelectPatchClass())
% C : intra-patch coordinates
% NW : coordinates for north-east vertex
% NE : coordinates for north-west vertex
% SW : coordinates for south-west vertex
% SE : coordinates for south-east vertex

function [C, NW, NE, SW, SE] = HealpixGetPatchVertexCoordsR(n, i, j, INFO)

% gradient of the border
grad = INFO.polar_part;

%north_west_j = fix(j - grad * INFO.decimal_i_n);
delta_int_i_n = INFO.int_i_n - 1;
north_west_j = grad + grad * delta_int_i_n;
south_west_j = north_west_j + grad;

north_i_n = INFO.int_i_n;
south_i_n = INFO.int_i_n + 1;

north_west_j = mod(north_west_j     - 1, 4 * north_i_n) + 1;
north_east_j = mod(north_west_j + 1 - 1, 4 * north_i_n) + 1;

south_west_j = mod(south_west_j     - 1, 4 * south_i_n) + 1;
south_east_j = mod(south_west_j + 1 - 1, 4 * south_i_n) + 1;

if INFO.is_south_pole == 0
    NW = [north_i_n, north_west_j];
    NE = [north_i_n, north_east_j];
    SW = [south_i_n, south_west_j];
    SE = [south_i_n, south_east_j];
    C = [INFO.decimal_i_n, INFO.polar_intra_part] - 0.5;
else
    north_i_n = 4 * n - north_i_n;
    south_i_n = 4 * n - south_i_n;
    NW = [south_i_n, south_west_j];
    NE = [south_i_n, south_east_j];
    SW = [north_i_n, north_west_j];
    SE = [north_i_n, north_east_j];
    C = [1 - INFO.decimal_i_n, INFO.polar_intra_part] - 0.5;
end
