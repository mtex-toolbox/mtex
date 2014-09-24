function parent = connectedComponents(A)
% label connected componentes in an graph (adjacency matrix)

%elimination tree
parent = etree(A);

isleaf = parent ~= 0;
parent(~isleaf) = 1:nnz(~isleaf);
i = find(isleaf);
for i = i(end:-1:1)
  parent(i) = parent(parent(i));
end
