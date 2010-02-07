function d = dot(o1,o2)
% compute minimum dot(o1,o2) modulo symmetry

%% get symmetries
if isa(o1,'orientation')
  domega = rotangle_max_z(o1.CS);
  qcs = quaternion_special(o1.CS);
  qss = quaternion(o1.SS);
else
  domega = rotangle_max_z(o2.CS);
  qcs = quaternion_special(o2.CS);
  qss = quaternion(o2.SS);
end
omega = 0:domega:2*pi-domega;

%% special cases

if numel(o1) == 1
  d = reshape(dot_outer(o1,o2),size(o2));
  return
elseif numel(o2) == 1
  d = reshape(dot_outer(o1,o2),size(o1));
  return
end



%% no specimen symmetry
d = dot_angle(o1,o2,omega);
for i = 2:length(qcs)
  ind = d < cos(domega/6);
  if ~any(ind), break;end
  d(ind) = max(d(ind),dot_angle(quaternion(o1,ind) * qcs(i),subsref(o2,ind),omega));
end

%% with specimen symmetry
if length(qss) > 1
  
  for j = 2:length(qss)

    sq1 = qss(j) * quaternion(o1);
    sdot = dot_angle(sq1,o2,omega);

    for i = 2:length(qcs)
      ind = sdot < cos(domega/6);
      if ~any(ind), break;end
      sdot(ind) = max(sdot(ind),dot_angle(sq1(ind)*qcs(i),subsref(o2,ind),omega));
    end
  
    d = max(dot,sdot);
  end
end
