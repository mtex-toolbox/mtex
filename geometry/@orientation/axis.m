function a = axis(o1,o2)
% rotational axis of an misorientation or two orientations
%
% Syntax
%   % define a cubic and hexagonal symmetries
%   csCube = crystalSymmetry('cubic')
%   csHex = crystalSymmetry('hexagonal')
%
%   % define two orientations
%   o1 = orientation('euler',csCube)
%   o2 = orientation('euler',csHex)
%
%   % the misorientation axis with respect to the specimen coordinate
%   % system is computed by
%   a = axis(o1,o2)  
%
%   % the misorientation axis with respect to csCube is computed by
%   a = axis(inv(o2)*o1)  
%
%   % the misorientation axis with respect to csHex is computed by
%   a = axis(inv(o1)*o2)  
%
% Input
%  mori,o1,o2 - @orientation
%
% Output
%  a - @vector3d
%  m - @Miller
%
% See also
% orientation/angle


if nargin == 1

  % project to Fundamental region to get the axis with the smallest angle
  o1 = project2FundamentalRegion(o1);
  a = axis@quaternion(o1);

  % add symmetry to axis
  if isa(o1.SS,'crystalSymmetry'), a = Miller(a,o1.SS); end

else
  
  [l,d,r] = factor(o1.CS,o2.CS);
  l = l * d;
  % we are looking for l,r from L and R such that
  % angle(o1*l , o2*r) is minimal
  % this is equivalent to 
  % angle(inv(o2)*o1 , r*inv(l)) is minimal

  q1 = quaternion(o1);
  q2 = quaternion(o2);
  q21 = inv(q2).*q1; %#ok<*MINV>
  rl = r * inv(l);
    
  d = -inf;
  irMax = zeros(size(q21));
  ilMax = zeros(size(q21));
  for il = 1:length(l)
    for ir = 1:length(r)
      dLocal = abs(dot(q21,rl(ir,il)));
      ind = dLocal > d;
      d = max(d,dLocal);
      irMax(ind) = ir;
      ilMax(ind) = il;
    end
  end

  % this projects q21 into the fundamental zone
  q = reshape(inv(r(irMax)),size(q21)) .* q21 .* reshape(l(ilMax),size(q21));
    
  % now the misorientation axis is given by in specimen coordinates is
  % given by o2 * l(il) * q.axis or equivalently by  
  a = q2 .* r(irMax) .* axis@quaternion(q);
  
end

