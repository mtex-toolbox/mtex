function d = dot(o1,o2,varargin)
% compute minimum dot(o1,o2) modulo symmetry
%
% Syntax
%   d = dot(o1,o2)
%
% Input
%  o1, o2 - @orientation
%
% Output
%  d = cos(omega/2) where omega is the smallest rotational angle of inv(o1)*o2
%
% See also
% orientation/dot_outer orientation/angle

if check_option(varargin,'noSymmetry')
  d = dot@rotation(o1,o2);
  return
end

% extract symmetries
if isa(o1,'orientation')

  qss = o1.SS;
  qcs = o1.CS;

  % check any of the involved symmetries is a Laue group as in this case we
  % can forget about all inversions
  isLaue = qss.isLaue || qcs.isLaue;

  if isa(o2,'orientation')

    % it is also possible to compute the misorientation angle between two
    % orientations of differernt phase. In this case the symmetry becomes
    % the product of both symmetries
    if o1.CS.Laue ~= o2.CS.Laue

      % this makes only sense when comparing orientations
      assert(isa(o1.CS,'crystalSymmetry') && isa(o1.CS,'crystalSymmetry') ...
       && isa(o1.SS,'specimenSymmetry') && o2.SS.Laue == o1.SS.Laue,...
       'Symmetry missmatch');

      isLaue = isLaue || o2.CS.isLaue;
      qcs = o1.CS' * o2.CS;
      qcs = unique(qcs(:));
      qss = rotation.id;

    elseif o1.SS.Laue ~= o2.SS.Laue % comparing inverse orientations

      assert(isa(o1.SS,'crystalSymmetry') && isa(o1.SS,'crystalSymmetry') ...
       && isa(o1.CS,'specimenSymmetry') && o2.CS.Laue == o1.CS.Laue,...
       'Symmetry missmatch');

      isLaue = isLaue || o2.SS.isLaue;
      qss = o1.SS' * o2.SS;
      qss = unique(qss(:));
      qcs = rotation.id;
    end
  end
else
  qcs = o2.CS;
  qss = o2.SS;
  isLaue = qss.isLaue || qcs.isLaue;
end

% we may restrict to purely rotational group if one of the following
% conditions is satified
% * one of the involved groups is a Laue group
% * all symmetries as well as all orientations are purely rotational
if isLaue || (~any(qcs.i(:)) && any(qss.i(:)) && ...
  (~isa(o1,'rotation') || ~isa(o2,'rotation') || all(o1.i(:) == o2.i(:))))

  q1 = quaternion(o1);
  q2 = quaternion(o2);
  qcs = unique(quaternion(qcs),'antipodal');
  qss = unique(quaternion(qss),'antipodal');

else % we have to live with inversion

  q1 = rotation(o1);
  q2 = rotation(o2);

end

% we have different algorithms depending whether one vector is single
if length(q1) == 1

  q1 = qss * q1 * qcs; % symmetrising the single element is much faster

  % this might save some time
  if length(q2) > 1000, q1 = unique(q1,'antipodal'); end

  % apply rotation / quaternion dot_outer and take the maximum
  d = reshape(max(abs(dot_outer(q1,q2)),[],1),size(q2));

else

  % symmetrise
  q1 = qss * q1;
  q2 = reshape(q2 * inv(qcs),[1,length(q2),length(qcs)]);

  % inline dot product for speed reasons
  d = abs(bsxfun(@times,q1.a,q2.a) + bsxfun(@times,q1.b,q2.b) + ...
    bsxfun(@times,q1.c,q2.c) + bsxfun(@times,q1.d,q2.d)); %

  % consider inversion
  if isa(q1,'rotation'), d = min(d,~bsxfun(@xor,q1.i,q2.i)); end

  % take the maximum over all symmetric equivalent
  d = reshape(max(max(d,[],1),[],3),size(o1));

end

% some testing code
% cs = crystalSymmetry('3m1')
% ori = [1,-1] .* orientation.id(cs)
% dot(ori,fliplr(ori))
% dot(ori,ori(2))
% dot(ori(2),cs(2))
% ori
% cs2 = crystalSymmetry('m-3m')
% ori1 = orientation.rand(20,20,cs)
% ori2 = orientation.rand(20,20,cs2)
% ori3 = orientation.rand(5,5,cs,cs2)
% hist((angle(ori1(1),ori2(1)) - angle(inv(ori1(1)).*ori2(1)))/degree)
% ori01 = orientation.byEuler(290*degree,100*degree,250*degree,cs)
% ori02 = orientation.byEuler(280*degree,90*degree,90*degree,cs2)
% angle(ori01,ori02) / degree      % not ok
% angle(ori02,ori01) / degree      % not ok
% angle(inv(ori02)*ori01) / degree % ok
% angle(inv(ori01)*ori02) / degree % ok
% min(angle_outer(ori02,ori01))./degree
%
% min(angle_outer(ori02*cs2,ori01*cs))./degree
% angle(ori3,ori3.')./degree
% angle(ori3(:,1),ori3(1,1)) - angle_outer(ori3(:,1),ori3(1,1))
