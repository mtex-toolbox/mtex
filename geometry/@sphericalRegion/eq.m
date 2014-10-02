function out = eq(sR1,sR2)

out = false;
sR1 = cleanUp(sR1);
sR2 = cleanUp(sR2);

% number of restrictions should be the same
if numel(sR1) ~= numel(sR2), return; end

% normals should fit
fit = dot_outer(sR1.N,sR2.N)>1-1e-6;

if nnz(fit) ~= length(sR1.alpha), return; end

% alphas should fit
[u,v] = find(fit);

out = all(sR1.alpha(u) == sR2.alpha(v));
