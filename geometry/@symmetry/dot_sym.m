function dot = dot_sym(q1,q2,cs,ss)
% compute minimum q1 q2 modulo symmetry

if nargin > 3
  qss = quaternion(ss);
else
  qss = [];
end

domega = rotangle_max_z(cs);
omega = 0:domega:2*pi-domega;
qcs = quaternion_special(cs);

%% no specimen symmetry
dot = dot_angle(q1,q2,omega);
for i = 2:length(qcs)
  ind = dot < cos(domega/6);
  if ~any(ind), break;end
  dot(ind) = max(dot(ind),dot_angle(q1(ind)*qcs(i),q2(ind),omega));
end

%% with specimen symmetry
if length(qss) > 1
  
  for j = 2:length(qss)

    sq1 = qss(j)*q1;
    sdot = dot_angle(sq1,q2,omega);

    for i = 2:length(qcs)
      ind = sdot < cos(domega/6);
      if ~any(ind), break;end
      sdot(ind) = max(sdot(ind),dot_angle(sq1(ind)*qcs(i),q2(ind),omega));
    end
  
    dot = max(dot,sdot);
  end
end
%qcs = quaternion_special(cs);
%for i = 2:length(qcs)
%  dot = max(dot,dot_angle(q1*qcs(i),q2,omega));
%end
