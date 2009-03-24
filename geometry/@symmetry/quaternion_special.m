function [q,rho] = quaternion_special(cs,varargin)
% returns symmetry elements different from rotation about c-axis

if nargout == 1
  switch cs.laue
    case {'-1','2/m'}
      q = cs.quat;
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = reshape(cs.quat,[],2);
      q = q(1,:);
    case {'-3','4/m','6/m'}
      q = cs.quat(1);
    case {'m-3','m-3m'}
      q = reshape(cs.quat,[],6);
      q = q(1,:);
  end
  q = q(:);
else
  
  switch cs.laue
    case {'-1','2/m'}
      q = cs.quat;
      v = vector3d;
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = cs.quat(1);
      v = cs.axis(1);
    case {'-3','4/m','6/m'}
      q = cs.quat(1);
      v = vector3d;
    case {'m-3','m-3m'}
      q = Axis(vector3d(1,1,1),3);
      v = vector3d(1,1,0);
  end
  
  [theta,rho] = vec2sph(v);
  
  q = q(:);
end

