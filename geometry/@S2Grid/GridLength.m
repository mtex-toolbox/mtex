function l = GridLength(N)
% number of elements of a list of grids

l = zeros(1,length(N));
for i = 1:length(N)
    l(i) = numel(N(i).Grid);
end
