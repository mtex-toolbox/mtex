function I_FD = remapIFD(out,ebsd)
% remap the site-indexed I_FD from the decomposition onto ebsd columns:
% each site that corresponds to an ebsd pixel keeps its column, an empty cell
% of a notIndexed hole joins a pixel of the same hole, the rest (empty holes,
% the exterior band) are dropped, leaving zero columns.

id = out.site2id;

% holes are the face-connected notIndexed sites, each takes its smallest ebsd id
h = find(out.isNotIdx);
lab = conncomp(graph(out.I_FD(:,h).' * out.I_FD(:,h),'omitselfloops')).';
rep = accumarray(lab, id(h), [], @min);
empty = isnan(id(h));
id(h(empty)) = rep(lab(empty));

% sites sharing a column merge, the faces between them vanish
has  = ~isnan(id);
I_FD = out.I_FD * sparse(find(has), id(has), 1, numel(id), length(ebsd));
I_FD = double(I_FD == 1);

end
