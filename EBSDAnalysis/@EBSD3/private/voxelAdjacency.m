function A = voxelAdjacency(sz)
% the adjacency of the voxels of a lattice of size sz along its three axes

n = prod(sz);
idx = reshape(1:n,sz);
i = []; j = [];
for a = 1:3
  lo = repmat({':'},1,3); hi = lo;
  lo{a} = 1:sz(a)-1; hi{a} = 2:sz(a);
  i = [i; reshape(idx(lo{:}),[],1)]; %#ok<AGROW>
  j = [j; reshape(idx(hi{:}),[],1)]; %#ok<AGROW>
end
A = sparse([i;j],[j;i],1,n,n);

end
