function q = getQuantile(x,p)
% linearly interpolated quantile of the finite entries of x

x = sort(x(:));
x = x(isfinite(x));

if isempty(x), q = NaN; return; end
if isscalar(x), q = x; return; end

pos = 1 + (numel(x) - 1) * min(max(p,0),1);
lo = floor(pos);
hi = ceil(pos);
q = (1 - (pos - lo)) * x(lo) + (pos - lo) * x(hi);

end
