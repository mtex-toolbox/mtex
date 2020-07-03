function a = axis(o1,varargin)
% rotational axis of an misorientation or two orientations
%
% Syntax
%   % define a cubic and hexagonal symmetries
%   csCube = crystalSymmetry('cubic')
%   csHex = crystalSymmetry('hexagonal')
%
%   % define two orientations
%   o1 = orientation.byEuler(0,0,0,csCube)
%   o2 = orientation.byEuler(10*degree,20*degree,30*degree,csHex)
%
%   % the misorientation axis with respect to the specimen coordinate
%   % system is computed by
%   a = axis(o1,o2)
%
%   % the misorientation axis with respect to csCube is computed by
%   a = axis(inv(o1)*o2,csCube)
%
%   % the misorientation axis with respect to csHex is computed by
%   a = axis(inv(o1)*o2,csHex)
%
%   % compute the misorientation axis ignoring symmetry
%   a = axis(inv(o1)*o2,'noSymmetry')
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

% axis(ori1,ori2) should return the misorientation axis in specimen
% coordinates
if nargin >= 2 && isa(varargin{1},'orientation')

  o2 = varargin{1};
  
  assert(isa(o1.CS,'crystalSymmetry') && isa(o2.CS,'crystalSymmetry') && ...
    isa(o1.SS,'specimenSymmetry') && isa(o2.SS,'specimenSymmetry'),...
    'The first two input arguments should be orientations.');
  
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
  irMax = ones(size(q21));
  ilMax = ones(size(q21));
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

  a.antipodal = check_option(varargin,'antipodal');

else

  % crystal symmetry specified -> apply it
  if nargin >= 2 && isa(varargin{1},'crystalSymmetry')
    cs = varargin{1};
  else  % no symmetry specified - take the disjoint
    cs = properGroup(disjoint(o1.CS,o1.SS));
  end
  if o1.antipodal, cs = cs.Laue; end
  
  % project to Fundamental region to get the axis with the smallest angle
  if ~check_option(varargin,'noSymmetry')
    o1 = project2FundamentalRegion(o1);
  end

  a = axis@quaternion(o1);

  % add symmetry to axis
  if isa(cs,'crystalSymmetry'), a = Miller(a,cs); end

end
