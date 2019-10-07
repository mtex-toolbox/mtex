% Get vertex coordinates for the patch type 'B'
% [C, N, S, W, E] = HealpixGetPatchVertexCoordsB(n, i, j, INFO)
%
% Parameters
% n : grid resolution
% i : ring index
% j : intra-ring index
% INFO : intermediate information (output of HealpixSelectPatchClass())
% C : intra-patch coordinates
% N : coordinates for north vertex
% S : coordinates for south vertex
% W : coordinates for west vertex
% E : coordinates for east vertex

function [C, N, S, W, E] = HealpixGetPatchVertexCoordsB(n, i, j, INFO)

% gradient of the border
grad = INFO.polar_part;

decimal_i = INFO.decimal_i_n;
decimal_j = INFO.decimal_polar_intra_part;

int_i = INFO.int_i_n;

if int_i == n
    int_j = fix(j);
    if int_j == 0
        int_j = 4 * INFO.int_i_n;
    end
    
    north_int_j = mod(int_j - grad - 1, 4 * (n - 1)) + 1;
    east_int_j = mod(int_j + 1 - 1, 4 * n) + 1;
    
    N = [int_i - 1, north_int_j];
    S = [int_i + 1, int_j];
    W = [int_i    , int_j];
    E = [int_i    , east_int_j];

    offset_j = 0.5 * decimal_i;
    C = [decimal_i, decimal_j + offset_j - 0.5];
else
    int_j = fix(j - grad * decimal_i);
    if int_j == 0
        int_j = 4 * n;
    end
    
    west_int_j = mod(int_j + grad - 1, 4 * n) + 1;
    east_int_j = mod(west_int_j + 1 - 1, 4 * n) + 1;
    
    N = [int_i    , int_j];
    S = [int_i + 2, west_int_j];
    W = [int_i + 1, west_int_j];
    E = [int_i + 1, east_int_j];
        
    offset_j = 0.5 * (1 - decimal_i);
    C = [decimal_i - 1, decimal_j + offset_j - 0.5];
end

if INFO.is_south_pole
    TMP = N;
    N = S;
    S = TMP;
    N(1) = 4 * n - N(1);
    S(1) = 4 * n - S(1);
    W(1) = 4 * n - W(1);
    E(1) = 4 * n - E(1);
    C(1) = -C(1);
end
