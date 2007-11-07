function s = GridSize(G,n)
% size of the grid

if nargin == 1
    s = size(G(1).Grid);
else
    s = size(G(1).Grid,n);
end
