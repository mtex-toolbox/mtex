function d = double(G)
% convert to double
 
for i = 1:length(G)
  G(i).points = reshape(G(i).points,1,[]);
end

d = [G.points];
