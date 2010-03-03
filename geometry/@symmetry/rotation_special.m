function [q,rho] = rotation_special(cs,varargin)
% returns symmetry elements different from rotation about c-axis
%
%% Input:
%  cs - @symmetry
%
%% Output
%  q   - symmetry elements other then rotation about the z-axis
%  rho - position of the mirroring plane

if nargout == 1
  switch cs.laue
    case {'-1','2/m'}
      q = cs.rotation;
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = reshape(cs.rotation,[],2);
      q = q(1,:);
    case {'-3','4/m','6/m'}
      q = cs.rotation(1);
    case {'m-3','m-3m'}
      q = reshape(cs.rotation,[],6);
      q = q(1,:);
  end
  q = q(:);
else
  
  switch cs.laue
    case {'-1','2/m'}
      q = cs.rotation;
      v = vector3d;
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = cs.rotation(1);
      v = vector3d(Miller(1,0,0,cs));
    case {'-3','4/m','6/m'}
      q = cs.rotation(1);
      v = vector3d;
    case {'m-3','m-3m'}
      q = Axis(vector3d(1,1,1),3);
      v = vector3d(1,1,0);
  end
  
  [theta,rho] = vec2sph(v);
  rho = mod(rho,rotangle_max_z(cs));
  
  q = q(:);
end

