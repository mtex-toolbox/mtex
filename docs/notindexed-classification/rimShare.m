function s = rimShare(ebsd,P,parts,omega)
% share of the rim of each part held by its largest orientation cluster, from
% the rim pixels alone: adjacent rim pixels within omega join, and so do the
% clusters whose first pixels are within omega
g = ebsd.gridify;
sz = size(P);
isInd = reshape(g.isIndexed,sz);
ph = reshape(g.phaseId,sz);
rot = g.rotations;
s = zeros(numel(parts),1);
nb = [-1 0 1 -1 1 -1 0 1; -1 -1 -1 0 0 1 1 1];
for k = 1:numel(parts)
  rim = find(imdilate(P == parts(k),true(3)) & isInd);
  isRim = false(sz); isRim(rim) = true;
  [r,c] = ind2sub(sz,rim);
  [a,b] = deal([]);
  for d = nb
    r2 = r + d(1); c2 = c + d(2);
    ok = r2 >= 1 & r2 <= sz(1) & c2 >= 1 & c2 <= sz(2);
    l2 = zeros(size(r)); l2(ok) = sub2ind(sz,r2(ok),c2(ok));
    ok(ok) = isRim(l2(ok));
    a = [a; rim(ok)]; b = [b; l2(ok)]; %#ok<AGROW>
  end
  [~,a] = ismember(a,rim); [~,b] = ismember(b,rim);
  j = sameOri(a,b);
  cl = conncomp(graph(a(j),b(j),[],numel(rim))).';
  % merge clusters by their first pixel
  [~,f] = unique(cl);
  [A,B] = meshgrid(f,f); m = A < B; A = A(m); B = B(m);
  j = sameOri(A,B);
  lab = conncomp(graph(cl(A(j)),cl(B(j)),[],max(cl))).';
  s(k) = max(accumarray(lab(cl),1)) / numel(rim);
end

  function t = sameOri(i,j)
    pi_ = ph(rim(i)); t = pi_ == ph(rim(j)) & pi_ > 1;
    for p = unique(pi_(t)).'
      x = t & pi_ == p;
      cs = ebsd.CSList(p);
      t(x) = angle(orientation(rot(rim(i(x))),cs),orientation(rot(rim(j(x))),cs)) < omega;
    end
  end
end
