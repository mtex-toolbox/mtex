function isX = sifCrossing(V,e,isM)
% the segments of e with isM that cross another one of e

isX = isM;
if ~any(isM), return; end

% candidates: the segments in a common bucket, twice the median segment long, of their boxes
a = V(e(:,1),:);
d = V(e(:,2),:) - a;
h = 2*median(vecnorm(d,2,2));
lo = floor(min(a,a+d) / h);
hi = floor(max(a,a+d) / h);
o = min(lo,[],1) - 2;
lo = lo - o; hi = hi - o;
sz = max(hi,[],1);

% only the segments whose box shares a bucket with a moved one
[~,key] = buckets(find(isM),lo,hi,sz);
C = zeros(sz); C(key) = 1; C = cumsum(cumsum(C,1),2);
q = @(i,j) C(i + (j-1)*sz(1));
near = q(hi(:,1),hi(:,2)) - q(lo(:,1)-1,hi(:,2)) - q(hi(:,1),lo(:,2)-1) + q(lo(:,1)-1,lo(:,2)-1) > 0;
[s,key] = buckets(find(near),lo,hi,sz);
[key,o] = sort(key);
s = s(o);
first = find([true; diff(key) > 0]);
g = cumsum([true; diff(key) > 0]);
n = diff([first; numel(s) + 1]);
q = find(isM(s));
m = n(g(q));
i = repelem(s(q),m,1);
j = s(repelem(first(g(q)) - 1,m,1) + (1:sum(m)).' - repelem(cumsum(m) - m,m,1));

% each pair once, proper crossings of segments without a common vertex
u = ~isM(j) | j > i;
i = i(u); j = j(u);
w = a(j,:) - a(i,:);
den = d(i,1).*d(j,2) - d(i,2).*d(j,1);
s = (w(:,1).*d(j,2) - w(:,2).*d(j,1)) ./ den;
t = (w(:,1).*d(i,2) - w(:,2).*d(i,1)) ./ den;
x = s > 1e-4 & s < 1-1e-4 & t > 1e-4 & t < 1-1e-4 & ~any(e(i,:) == e(j,1) | e(i,:) == e(j,2),2);
isX = false(size(e,1),1);
isX([i(x); j(x)]) = true;
isX = isX & isM;

end

function [s,key] = buckets(j,lo,hi,sz)
% the segments j once for every bucket of their box, and its linear index
w = hi(j,1) - lo(j,1) + 1;
n = w .* (hi(j,2) - lo(j,2) + 1);
s = repelem(j,n,1);
r = (1:numel(s)).' - repelem(cumsum(n) - n,n,1) - 1;
w = repelem(w,n,1);
key = lo(s,1) + mod(r,w) + (lo(s,2) + floor(r ./ w) - 1) * sz(1);
end

