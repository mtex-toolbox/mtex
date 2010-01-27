function dot = dot(o1,o2)
% compute minimum dot(o1,o2) modulo symmetry


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


%% no specimen symmetry
dot = dot_angle(o1,o2,omega);
for i = 2:length(qcs)
  ind = dot < cos(domega/6);
  if ~any(ind), break;end
  dot(ind) = max(dot(ind),dot_angle(subsref(o1,ind) * qcs(i),subsref(o2,ind),omega));
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
  
    dot = max(dot,sdot);
  end
end
