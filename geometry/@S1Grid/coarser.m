function G = coarser(G)
% makes S1Grid more coarse

for i = 1:length(G)
    G.points(1:2:end) = [];
end

