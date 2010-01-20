function dot = dot(o1,o2)
% compute minimum o1 o2 modulo symmetry

if nargin > 3
  qss = quaternion(o1.ss);
else
  qss = [];
end

domega = rotangle_max_z(o1.CS);
omega = 0:domega:2*pi-domega;
qcs = quaternion_special(o1.CS);

%% no specimen symmetry
dot = dot_angle(o1.quaternion,o2.quaternion,omega);
for i = 2:length(qcs)
  ind = dot < cos(domega/6);
  if ~any(ind), break;end
  dot(ind) = max(dot(ind),dot_angle(o1.quaternion(ind)*qcs(i),o2.quaternion(ind),omega));
end

%% with specimen symmetry
if length(qss) > 1
  
  for j = 2:length(qss)

    sq1 = qss(j)*o1.quaternion;
    sdot = dot_angle(sq1,o2.quaternion,omega);

    for i = 2:length(qcs)
      ind = sdot < cos(domega/6);
      if ~any(ind), break;end
      sdot(ind) = max(sdot(ind),dot_angle(sq1(ind)*qcs(i),o2.quaternion(ind),omega));
    end
  
    dot = max(dot,sdot);
  end
end
