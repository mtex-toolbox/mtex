function d = ensureNonNeg(d)
% remove small negative values

if min(d(:)) > -1e-5, d = max(d,0);end
