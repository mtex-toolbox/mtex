function gid = gridComponents(ebsd,gbc,varargin)
% lazy grain sizing: connected components of the grid neighbourhood
% (stencil + diagonals), masked by the boundary criterion. Returns a grain
% id per ebsd pixel (0 for none). Cheaper than a full decomposition but
% blind to adjacencies that only exist across alpha-bridged gaps, so it may
% over-cull.

[A,stencil,~] = latticeBasis(ebsd.unitCell);
pos    = [ebsd.pos.x(:), ebsd.pos.y(:)];
origin = min(pos,[],1);
ij     = round((pos - origin) / A');
nE     = size(pos,1);
isIndexed = ebsd.isIndexed(:);

ijmin = min(ij,[],1);
ijsz  = max(ij,[],1) - ijmin + 1;
ij2slot = @(IJ) (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ij2ebsd = zeros(prod(ijsz),1);
ij2ebsd(ij2slot(ij)) = 1:nE;

% neighbourhood = stencil plus the diagonals between consecutive axis steps
% (for a 4-stencil this is the 8-neighbourhood; for hex, the 6 axial
% neighbours already cover the close-packed ring, diagonals add the rest)
diagsq = [1 1; 1 -1; -1 1; -1 -1];
nb = unique([stencil; diagsq],'rows');

P = []; Q = [];
for s = 1:size(nb,1)
  nbIJ  = ij + nb(s,:);
  inside = all(nbIJ >= ijmin & nbIJ <= ijmin+ijsz-1, 2);
  src = find(inside & isIndexed);
  dst = ij2ebsd(ij2slot(nbIJ(src,:)));
  ok  = dst > 0 & isIndexed(max(dst,1)) & dst > src;
  P = [P; src(ok)]; Q = [Q; dst(ok)]; %#ok<AGROW>
end

% merge where the criterion says same grain, split otherwise. This matches
% doSegmentation, which builds the intra-grain adjacency A_Do from connect>0.
connect = gbc.eval(ebsd,P,Q) > 0;
gid = conncomp(graph(P(connect),Q(connect),[],nE)).';
gid(~isIndexed) = 0;  % only size indexed pixels
end