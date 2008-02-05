function q = quaternion_special(cs,varargin)
% returns symmetry elements different from rotation about c-axis

switch cs.laue
  case {'-1','2/m'}
    q = cs.quat;
  case {'mmm','-3m','4/mmm','6/mmm'}
    q = cs.quat(1,:);
  case {'-3','4/m','6/m'}
    q = cs.quat(1);
  case {'m-3','m-3m'}
    q = reshape(cs.quat,[],6);
    q = q(1,:);
end
q = q(:);

