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
% Options
%  noSymmetry - ignore symmetry
%  max        - return the axis corresponding to the largest rotational angle
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
 
  if o1.CS == o1.SS
  
    if numel(o1.a) <= numel(o2.a)
      po2 = project2FundamentalRegion(o2, o1);
      mori = inv(po2) .* o1;

      a = o1 .* mori.axis('noSymmetry');
    else
      po1 = project2FundamentalRegion(o1, o2);
      mori = inv(po1) .* o2;

      a = - o2 .* mori.axis('noSymmetry');
    end
  
  else
    
    [l,d,r] = factor(o1.CS.properGroup,o2.CS.properGroup);
    l = l * d;
    % we are looking for l,r from L and R such that
    % angle(o1*l , o2*r) is minimal
    % this is equivalent to angle(inv(o2)*o1 , r*inv(l)) is minimal

    mori = inv(o2) .* o1; %#ok<*MINV>
    idSym = r * inv(l);

    d = -inf(size(mori));
    idMax = ones(size(mori));
    for id = 1:length(idSym)
      dLocal = dot(mori,idSym(id),'noSymmetry');
      idMax(dLocal > d) = id;
      d = max(d,dLocal);
    end

    % this projects mori into the fundamental zone
    [row,col] = ind2sub(size(idSym),idMax);
    pMori = times(inv(r(row)), mori, 0) .* reshape(l(col),size(col)); 

    % now the misorientation axis is given by in specimen coordinates is
    % given by either of the following two lines
    %ax = times(o1, l(col), 1) .* axis(pMori);
    a = times(o2, r(row), 1) .* axis(pMori);
        
  end

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
  if check_option(varargin,'max')
    % do not care about inversion
    q = quaternion(o1);
  
    % for misorientations we do not have to consider all symmetries
    [l,d,r] = factor(o1.CS,o1.SS);
    dr = d * r;
    qs = inv(l) * inv(dr);
  
    % compute all distances to the symmetric equivalent orientations
    % and take the minimum
    [~,pos] = min(abs(dot_outer(q,qs)),[],2);

    [il,idr] = ind2sub([length(l),length(dr)],pos);

    o1 = l(il) .* o1 .* dr(idr);

  elseif ~check_option(varargin,'noSymmetry')
    o1 = project2FundamentalRegion(o1);
  end

  a = axis@quaternion(o1);

  % add symmetry to axis
  if isa(cs,'crystalSymmetry'), a = Miller(a,cs); end

end
