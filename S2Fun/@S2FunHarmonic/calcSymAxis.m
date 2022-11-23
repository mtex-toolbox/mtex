function v = calcSymAxis(S2F,varargin)

v = equispacedS2Grid('resolution',5*degree,'antipodal');

err = nan(size(v));

for i = 1:length(v)
  err(i) = norm(S2F - S2F.symmetrise(v(i)));
end

[~,id] = min(err);

% refine
v2 = equispacedS2Grid('resolution',0.5*degree,'maxTheta',5*degree,'center',v(id));

err = nan(size(v2));
for i = 1:length(v2)
  err(i) = norm(S2F - S2F.symmetrise(v2(i)));
end

[~,id] = min(err);
v = v2(id);