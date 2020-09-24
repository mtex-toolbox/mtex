function criterion = gbc_angle(q,CS,Dl,Dr,threshold,varargin)
%

d = angle(orientation(q(Dl),CS),orientation(q(Dr),CS));

if length(threshold) == 1

  criterion = d < threshold;

else
  
  criterion = 0.5 * ((d < threshold(1)) + (d < threshold(2)));
  
end

% now check whether the have a misorientation heigher or lower than a
% threshold
%m = inv(q(Dl)).*q(Dr);

%criterion = abs(dot(m,quaternion.id)) > cos(threshold/2);

%if any(~criterion)
%  qcs = quaternion(CS.properGroup);
%  criterion(~criterion) = max(abs(dot_outer(m(~criterion),qcs)),[],2) > cos(threshold/2);
%end 

% o_Dl = orientation(q(Dl),CS,symmetry);
% o_Dr = orientation(q(Dr),CS,symmetry);
% criterion = dot(o_Dl,o_Dr) > cos(threshold/2);
