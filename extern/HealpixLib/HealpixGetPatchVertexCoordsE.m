% Get vertex coordinates for the patch type 'E'
% [C, N, S, W, E] = HealpixGetPatchVertexCoordsE(n, i, j)
%
% Parameters
% n : grid resolution
% i : ring index
% j : intra-ring index
% C : intra-patch coordinates
% N : coordinates for north vertex
% S : coordinates for south vertex
% W : coordinates for west vertex
% E : coordinates for east vertex

function [C, N, S, W, E] = HealpixGetPatchVertexCoordsE(n, i, j)

int_i = fix(i);
int_j = fix(j);
decimal_i = i - int_i;
decimal_j = j - int_j;

if int_j == 0
    int_j = 4 * n;
end

east_int_j = mod(int_j + 1 - 1, 4 * n) + 1;

if mod(int_i - n, 2) == 0
    if decimal_i < 1 - decimal_j
        N = [int_i - 1, int_j];
        S = [int_i + 1, int_j];
        W = [int_i    , int_j];
        E = [int_i    , east_int_j];
        
        offset_j = 0.5 * decimal_i;
        C = [decimal_i, decimal_j + offset_j - 0.5];
    else
        N = [int_i    , east_int_j];
        S = [int_i + 2, east_int_j];
        W = [int_i + 1, int_j];
        E = [int_i + 1, east_int_j];

        offset_j = 0.5 * (1 - decimal_i);
        C = [decimal_i - 1, decimal_j - offset_j - 0.5];
    end
else
	if decimal_i < decimal_j
        N = [int_i - 1, east_int_j];
        S = [int_i + 1, east_int_j];
        W = [int_i    , int_j];
        E = [int_i    , east_int_j];

        offset_j = 0.5 * decimal_i;
        C = [decimal_i, decimal_j - offset_j - 0.5];
    else
        N = [int_i    , int_j];
        S = [int_i + 2, int_j];
        W = [int_i + 1, int_j];
        E = [int_i + 1, east_int_j];
        
        offset_j = 0.5 * (1 - decimal_i);
        C = [decimal_i - 1, decimal_j + offset_j - 0.5];
    end
end
