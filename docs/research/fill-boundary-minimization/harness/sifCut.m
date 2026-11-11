function [V,F,I_FD,isB] = sifCut(V,F,I_FD,grainId,out)
% the boundary segments cut where they enter the filled cells, isB the boundary segments

inFill = out.inFill;

% segments between two grains or at the outer boundary
[f,d] = find(I_FD);
nF = size(F,1);
isB = accumarray(f,grainId(d),[nF 1],@min) ~= accumarray(f,grainId(d),[nF 1],@max) | ...
  accumarray(f,1,[nF 1]) == 1;

% a boundary segment gets a vertex where it enters the filled cells, twice, so the pieces are cut again
tol = out.epsilon;
look = isB;
for pass = 1:2
  look = find(look);
  dE = reshape(inFill(V(F(look,:),:)),[],2);
  isC = max(dE,[],2) > tol & min(dE,[],2) < -tol;
  k = ~isC & max(dE,[],2) > tol;
  [c2,a2,b2] = fillEntry(V,F,look(k),dE(k,:),inFill,tol,out.dxy);
  cut = [look(isC); c2];
  a = [V(F(look(isC),1),:); a2]; b = [V(F(look(isC),2),:); b2];
  lo = zeros(numel(cut),1); hi = ones(numel(cut),1);
  aIn = inFill(a) > 0;
  for it = 1:16
    mid = (lo + hi) / 2;
    isA = (inFill(a + mid .* (b - a)) > 0) == aIn;
    lo(isA) = mid(isA); hi(~isA) = mid(~isA);
  end
  nV = size(V,1); nF = size(F,1);
  V = [V; a + (lo + hi) / 2 .* (b - a)]; %#ok<AGROW>
  F = [F; nV + (1:numel(cut)).', F(cut,2)]; %#ok<AGROW>
  F(cut,2) = nV + (1:numel(cut)).';
  if pass > 1, [f,d] = find(I_FD); end
  r = zeros(nF,1); r(cut) = nF + (1:numel(cut)); s = r(f) > 0;
  I_FD = sparse([f; r(f(s))], [d; d(s)], 1, nF + numel(cut), size(I_FD,2));
  isB = [isB; true(numel(cut),1)]; %#ok<AGROW>
  look = false(size(F,1),1); look([cut; nF + (1:numel(cut)).']) = true;
end

end

function [k,a,b] = fillEntry(V,F,k,dE,inFill,tol,dxy)
% of the segments k with an end inside the fill those that leave it in
% between: that end, the first if both are, and the sample outside nearest to it

in1 = dE(:,1) > tol;
a = V(F(k,2),:); a(in1,:) = V(F(k(in1),1),:);
b = V(F(k,1),:); b(in1,:) = V(F(k(in1),2),:);
T = max(2,ceil(3 * vecnorm(b - a,2,2) / dxy));
s = repelem((1:numel(k)).',T-1,1);
t = ((1:numel(s)).' - repelem(cumsum(T-1) - (T-1),T-1,1)) ./ T(s);
isO = inFill(a(s,:) + t .* (b(s,:) - a(s,:))) < -tol;
t = accumarray(s(isO,1),t(isO,1),[numel(k) 1],@min,inf);
o = isfinite(t);
k = k(o); a = a(o,:); b = a + t(o,1) .* (b(o,:) - a);

end
