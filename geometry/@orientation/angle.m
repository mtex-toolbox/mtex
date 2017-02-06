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

if nargin >= 2 && isa(varargin{1},'quaternion')

  omega = real(2*acos(abs(dot(o1,varargin{:}))));
  
elseif nargin >= 2 && isa(varargin{1},'fibre')
  
    omega = angle(varargin{1},o1,varargin{2:end});
  
elseif check_option(varargin,'noSymmetry')
  
  omega = angle@quaternion(o1);
  
else
  
  % do not care about inversion
  q = quaternion(o1);
  
  % for misorientations we do not have to consider all symmetries
  [l,d,r] = factor(o1.CS,o1.SS);
  dr = d * r;
  qs = l * dr;
  
  % may be we can skip something
  minAngle = reshape(abs(qs.angle),[],1);
  minAngle = min([inf;minAngle(minAngle > 1e-3)]);
  omega = 2 * real(acos(abs(q.a)));
  notInside = omega > minAngle/2;
  
  % compute all distances to the symmetric equivalent orientations
  % and take the minimum
  omega(notInside) = 2 * real(acos(max(abs(dot_outer(q.subSet(notInside),qs)),[],2)));
    
end
