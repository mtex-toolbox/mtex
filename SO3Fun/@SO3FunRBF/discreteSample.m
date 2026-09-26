function ori = discreteSample(SO3F,npoints,varargin)
% draw a random sample
%

nF = numel(SO3F);
K = size(SO3F.weights,1);

% the center of every sample, K+1 for the uniform portion c0, NaN for a
% function without mass
if isempty(SO3F.weights)
  ic = ones(npoints,nF);
else
  ic = nan(npoints,nF);
  for k = 1:nF
    x = [full(SO3F.weights(:,k));SO3F.c0(k)];
    if sum(x)>0, ic(:,k) = aliasSample(x,npoints); end
  end
end
ic = ic(:);
a = nan(size(ic)); b = a; c = a; d = a; inv = false(size(ic));

% the uniform random orientations
isUniform = ic == K+1;
if any(isUniform)
  q = randn(4,nnz(isUniform)); q = q ./ vecnorm(q);
  a(isUniform) = q(1,:); b(isUniform) = q(2,:); c(isUniform) = q(3,:); d(isUniform) = q(4,:);
end

% the others are the center times a rotation about a random axis by an
% angle from the inverse distribution function of the kernel
isRBF = ic <= K;
m = nnz(isRBF);
if m > 0
  axis = randn(3,m); axis = axis ./ vecnorm(axis);
  M = 1000000; % discretization parameter
  hw = min(4*SO3F.psi.halfwidth,90*degree);
  t = linspace(cos(hw),1,M);
  cdf = cumsum(sqrt(1-t.^2) .* SO3F.psi.eval(t));
  % the inverse distribution function on P points, linear in between
  [cdf,iu] = unique([0,cdf/cdf(end)]); t = [t(1),t]; t = t(iu);
  P = 2^14; tinv = interp1(cdf,t,linspace(0,1,P));
  u = rand(m,1)*(P-1); j = min(floor(u),P-2); u = u-j;
  ct = tinv(j+1).' .* (1-u) + tinv(j+2).' .* u; % cos of half the angle
  s = sqrt(1-ct.^2);
  ctr = SO3F.center; cq = [ctr.a(:),ctr.b(:),ctr.c(:),ctr.d(:)]; cq = cq(ic(isRBF),:);
  if any(ctr.i), inv(isRBF) = ctr.i(ic(isRBF)); end
  [a(isRBF),b(isRBF),c(isRBF),d(isRBF)] = qmult(cq(:,1),cq(:,2),cq(:,3),cq(:,4), ...
    ct,s.*axis(1,:).',s.*axis(2,:).',s.*axis(3,:).');
end

% a random element of each symmetry
[a,b,c,d,inv] = symmetryElement(a,b,c,d,inv,SO3F.CS,true);
if SO3F.SS.numSym > 1, [a,b,c,d,inv] = symmetryElement(a,b,c,d,inv,SO3F.SS,false); end

rot = rotation(quaternion(a,b,c,d));
if any(inv), rot.i = inv; end
ori = reshape(orientation(rot,SO3F.CS,SO3F.SS),npoints,nF);
if npoints == 1, ori = reshape(ori,size(SO3F)); end

end


function [a,b,c,d] = qmult(a1,b1,c1,d1,a2,b2,c2,d2)
% the quaternion product (a1,b1,c1,d1) * (a2,b2,c2,d2)
a = a1.*a2 - b1.*b2 - c1.*c2 - d1.*d2;
b = a1.*b2 + b1.*a2 + c1.*d2 - d1.*c2;
c = a1.*c2 - b1.*d2 + c1.*a2 + d1.*b2;
d = a1.*d2 + b1.*c2 - c1.*b2 + d1.*a2;
end


function [a,b,c,d,inv] = symmetryElement(a,b,c,d,inv,S,right)
% multiply by a random element of S from the right or the left
g = S.rot;
k = randi(S.numSym,size(a));
e = @(x) reshape(x(k),size(k));
if right
  [a,b,c,d] = qmult(a,b,c,d,e(g.a),e(g.b),e(g.c),e(g.d));
else
  [a,b,c,d] = qmult(e(g.a),e(g.b),e(g.c),e(g.d),a,b,c,d);
end
if any(g.i), inv = xor(inv,e(g.i)); end
end


function ic = aliasSample(w,n)
% n indices drawn with the weights w by Walker's alias method
K = numel(w);
p = K * w(:) / sum(w);
prob = ones(K,1); alias = (1:K)';
small = find(p < 1); large = find(p >= 1);
ns = numel(small); nl = numel(large);
while ns > 0 && nl > 0
  sm = small(ns); lg = large(nl); ns = ns - 1;
  prob(sm) = p(sm); alias(sm) = lg;
  p(lg) = p(lg) + p(sm) - 1;
  if p(lg) < 1, nl = nl - 1; ns = ns + 1; small(ns) = lg; end
end
u = rand(n,1) * K;
ic = min(floor(u),K-1) + 1;
take = u - ic + 1 >= prob(ic);
ic(take) = alias(ic(take));
end
