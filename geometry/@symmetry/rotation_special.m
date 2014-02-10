function [q,rho] = rotation_special(cs,varargin)
% returns symmetry elements different from rotation about c-axis
%
% Input:
%  cs - @symmetry
%
% Output
%  q   - symmetry elements other then rotation about the z--axis
%  rho - position of the mirroring plane

if nargout == 1
  switch cs.laueGroup
    case {'-1','2/m'}
      q = rotation(cs);
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = reshape(cs,[],2);
      q = q(1,:);
    case {'-3','4/m','6/m'}
      q = cs(1);      
    case {'m-3','m-3m'}
      q = reshape(cs,[],6);
      q = q(1,:);
  end
  q = q(:);
else % TODO
  
  switch cs.laueGroup
    case '-1'
      q = idquaternion;
      v = vector3d;
    case '2/m'
      rot = rotation(cs);
      v = rot(2).axis;
      if isnull(dot(v,zvector))
        q = idquaternion;
      else
        v = vector3d;
        q = idquaternion;
      end            
    case {'mmm','-3m','4/mmm','6/mmm'}
      q = idquaternion;
      v = cs.axes(1);
    case {'-3','4/m','6/m'}
      q = idquaternion;
      v = vector3d;
    case 'm-3'
      q = Axis(vector3d(1,1,1),3);
      v = vector3d(1,0,0);
    case 'm-3m'
      q = Axis(vector3d(1,1,1),3);
      v = vector3d(1,1,0);
  end
  
  rho = mod(v.rho,cs.rotangle_max_z);
  
  q = q(:);
end

