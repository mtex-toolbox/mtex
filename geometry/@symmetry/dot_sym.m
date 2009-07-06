function dot = dot_sym(q1,q2,cs,ss)
% compute minimum q1 q2

if nargin > 3
  qss = quaternion(ss);
else
  qss = [];
end

domega = rotangle_max_z(cs);
omega = 0:domega:2*pi-domega;
dot = dot_angle(q1,q2,omega);

qcs = quaternion_special(cs);
for i = 2:length(qcs)
 ind = dot < cos(domega/6);
 if ~any(ind), return;end
 dot(ind) = max(dot(ind),dot_angle(q1(ind)*qcs(i),q2(ind),omega));
end

%qcs = quaternion_special(cs);
%for i = 2:length(qcs)
%  dot = max(dot,dot_angle(q1*qcs(i),q2,omega));
%end
