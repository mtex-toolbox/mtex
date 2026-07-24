function I_FD = remapIFD(out,ebsd)
% remap the site-indexed I_FD from the decomposition onto ebsd columns:
% each site that corresponds to an ebsd pixel keeps its column, the rest
% (empty-cell notIndexed sites) are dropped, leaving zero columns.

has  = ~isnan(out.site2id);
I_FD = sparse(size(out.I_FD,1), length(ebsd));
I_FD(:, out.site2id(has)) = out.I_FD(:, has);

end