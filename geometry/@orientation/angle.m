function omega = angle(o1,varargin)
% calculates rotational angle between orientations
%
% Syntax  
%   omega = angle(o)
%   omega = angle(o,'noSymmetry') % ignore symmetry equivalents
%   omega = angle(o1,o2)
%
% Input
%  o1, o2 - @orientation
% 
% Output
%  o1 x o2 - angle (double)
%
% Options
%  noSymmetry - do ignore symmetry
%  noSym1, noSym2 - do ignore only left or right symmetry
%  max        - return the maximum rotational angle from all symmetrically equivalent
%

if nargin >= 2 && isa(varargin{1},'quaternion')

  omega = real(2*acos(abs(dot(o1,varargin{:}))));
  
elseif nargin >= 2 && isa(varargin{1},'fibre')
  
  omega = angle(varargin{1},o1,varargin{2:end});
  
elseif check_option(varargin,'noSymmetry')
  
  omega = angle@quaternion(o1);
  
elseif check_option(varargin,'max')
  
  % do not care about inversion
  q = quaternion(o1);
  
  % for misorientations we do not have to consider all symmetries
  [l,d,r] = factor(o1.CS,o1.SS);
  dr = d * r;
  qs = l * dr;
  
  % compute all distances to the symmetric equivalent orientations
  % and take the minimum
  omega = 2 * real(acos(min(abs(dot_outer(q,qs)),[],2)));
  
elseif check_option(varargin,'noSym2') || o1.SS.id == 1 || o1.SS.id == 1
  % consider only first symmetry
  
  omega = min(angle_outer(o1,o1.CS.properGroup.rot,'noSymmetry'),[],2);
  omega = reshape(omega,size(o1));
  
elseif check_option(varargin,'noSym1') || o1.CS.id == 1 || o1.CS.id == 1
  % consider only second symmetry
  
  omega = min(angle_outer(o1,o1.SS.properGroup.rot,'noSymmetry'),[],2);
  omega = reshape(omega,size(o1));
  
else
    
  % symmetrical equivalents of the identity 
  idSym = unique(o1.SS.properGroup.rot * o1.CS.properGroup.rot);
  
  % may be we can skip something
  minAngle = reshape(abs(idSym.angle),[],1);
  minAngle = min([inf;minAngle(minAngle > 1e-3)]);
  omega = 2 * real(acos(abs(o1.a)));
  notInside = omega > minAngle/2;
  
  % angle is minimum distance to idSym
  if any(notInside)
    omega(notInside) = min(angle_outer(o1.subSet(notInside),idSym,'noSymmetry'),[],2);
  end

end
