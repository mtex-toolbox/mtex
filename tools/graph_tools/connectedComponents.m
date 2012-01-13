function ids = connectedComponents(A)
% label connected componentes in an graph (adjacency matrix)

%elimination tree
parent = etree(A);

n = length(parent);
ids = zeros(1,n);
isleaf = parent ~= 0;

k = sum(~isleaf);
%set id for each tree in forest
for i = n:-1:1,
  if isleaf(i)
    ids(i) = ids(parent(i));
  else
    ids(i) = k;
    k = k - 1;
  end
end;
