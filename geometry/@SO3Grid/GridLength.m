function l = GridLength(N)
% totalsize of SO3Grids

for i = 1:length(N)
    l(i) = numel(N(i).Grid); %#ok<AGROW>
end
