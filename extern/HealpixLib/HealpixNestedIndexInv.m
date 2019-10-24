% pn = HealpixNestedIndexInv(n, i, j)
% Parameters
% n : resolution of the grid (N_side)
% i : ring index
% j : pixel in ring index

function pn = HealpixNestedIndexInv(n, i, j)

persistent HNII_MAP hnii_n

if length(hnii_n) == 0 || hnii_n ~= n
    % create the inverse mapping table from the forward solution
    hnii_n = n;
    HNII_MAP = zeros(4 * n - 1, 4 * n, 'uint16');
    n_total = 12 * n^2;
    for k = 0:(n_total - 1)
        IDX = HealpixNestedIndex(n, k);
        HNII_MAP(IDX(1), IDX(2)) = uint16(k);
    end
end

pn = HNII_MAP(i, j);
