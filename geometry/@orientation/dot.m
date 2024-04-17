function d = dot(o1,o2,varargin)
% compute maximum dot(o1,o2) modulo symmetry
%
% Syntax
%   d = dot(o1,o2)
%
%   d = dot(o1,o2,'noSymmetry')
%
% Input
%  o1, o2 - @orientation
%
% Output
%  d - cos(omega/2) where omega is the smallest rotational angle of inv(o1)*o2
%
% Options
%  noSymmetry - ignore all symmetries
%
% See also
% orientation/dot_outer orientation/angle

if check_option(varargin,'noSymmetry')
  d = dot@rotation(o1,o2,varargin{:});
  return
end

% extract symmetries
if isa(o1,'orientation')

  % check any of the involved symmetries is a Laue group as in this case we
  % can forget about all inversions
  oneIsLaue = isLaue(o1.SS) || isLaue(o1.CS);

  if oneIsLaue
    qss = o1.SS.properGroup.rot;
    qcs = o1.CS.properGroup.rot;
  else
    qss = o1.SS.rot;
    qcs = o1.CS.rot;
  end
  
  if isa(o2,'orientation')

    % it is also possible to compute the misorientation angle between two
    % orientations of different phase. In this case the symmetry becomes
    % the product of both symmetries
    if o1.CS.Laue ~= o2.CS.Laue

      try 
        o2 = ensureCS(o1.CS,o2);
      catch
      
        % this makes only sense when comparing orientations
        assert(isa(o1.CS,'crystalSymmetry') && isa(o2.CS,'crystalSymmetry') ...
          && isa(o1.SS,'specimenSymmetry') && o2.SS.Laue == o1.SS.Laue,...
          'Symmetry missmatch');

        oneIsLaue = oneIsLaue || isLaue(o2.CS);
        qcs = o1.CS.rot' * o2.CS.rot;
        qcs = unique(qcs(:));
        qss = rotation.id;
        
      end

    elseif o1.SS.Laue ~= o2.SS.Laue % comparing inverse orientations

      assert(isa(o1.SS,'crystalSymmetry') && isa(o2.SS,'crystalSymmetry') ...
       && isa(o1.CS,'specimenSymmetry') && o2.CS.Laue == o1.CS.Laue,...
       'Symmetry missmatch');

      oneIsLaue = oneIsLaue || isLaue(o2.SS);
      qss = o1.SS.rot' * o2.SS.rot;
      qss = unique(qss(:));
      qcs = rotation.id;
    end
  end
  
  if check_option(varargin,'noSym2'), qss = []; end
  if check_option(varargin,'noSym1'), qcs = []; end
  
else
  
  oneIsLaue = isLaue(o2.SS) || isLaue(o2.CS);
  
  if oneIsLaue
    qss = o2.SS.properGroup.rot;
    qcs = o2.CS.properGroup.rot;
  else
    qss = o2.SS.rot;
    qcs = o2.CS.rot;
  end
  
end

% we may restrict to purely rotational group if one of the following
% conditions is satified
% * one of the involved groups is a Laue group
% * all symmetries as well as all orientations are purely rotational

ignoreInv = ( oneIsLaue || ... TODO - here is missing a condition
  (~isa(o1,'rotation') || ~isa(o2,'rotation') || all(o1.i == o2.i,'all')));


% we have different algorithms depending whether one vector is single
if length(qss) <= 1 % no specimen symmetry

  % this is inv(o1) .* o2
  mori = itimes(o1,o2,1);

  % take the maximum over all symmetric equivalent
  d = max(dot_outer(mori,qcs,'noSymmetry'),[],2);

  d = reshape(d,size(mori));
  
elseif length(qcs) <= 1 % no crystal symmetry
  
  % this is o1 .* inv(o2)
  mori = itimes(o1,o2,0);

  % take the maximum over all symmetric equivalent
  d = max(dot_outer(mori,qss,'noSymmetry'),[],2);
      
  d = reshape(d,size(mori));

elseif isscalar(o1)

  % symmetrising the single element is much faster
  o1 = mtimes(qss,mtimes(o1,qcs,0),1);
  
  % inline dot_outer(o1,o2) for speed reasons
  q1 = [o1.a(:) o1.b(:) o1.c(:) o1.d(:)];
  q2 = [o2.a(:) o2.b(:) o2.c(:) o2.d(:)];
  
  d = q1 * q2.';
  
  % consider inversion if needed
  if ~ignoreInv, d = d .* ~bsxfun(@xor,o1.i(:),o2.i(:).'); end
  
  d = reshape(max(abs(d),[],1),size(o2));
  
elseif isscalar(o2)
  
  % symmetrising the single element is much faster
  o2 = mtimes(qss,mtimes(o2,qcs,0),1);
  
  % inline dot_outer(o1,o2) for speed reasons
  q1 = [o1.a(:) o1.b(:) o1.c(:) o1.d(:)];
  q2 = [o2.a(:) o2.b(:) o2.c(:) o2.d(:)];
  
  d = q1 * q2.';
  
  % consider inversion if needed
  if ~ignoreInv, d = d .* ~bsxfun(@xor,o1.i(:),o2.i(:).'); end
  
  d = reshape(max(abs(d),[],2),size(o1));
  
else % length(qss)>1 and two vectors to compare

  % remember shape

  % symmetrise o1 by qss and o2 by qcs
  if all(size(o1)==size(o2))
    s = size(o1);
    o1 = mtimes(qss,o1,1);
    o2 = reshape(mtimes(o2,inv(qcs),0),[1,length(o2),length(qcs)]);
  else
    s = [length(o1),length(o2)];
    o1 = mtimes(qss,o1,1);
    o2 = reshape(mtimes(o2,inv(qcs),0),[1,1,length(o2),length(qcs)]);
  end

  % inline dot product for speed reasons
  d = abs(bsxfun(@times,o1.a,o2.a) + bsxfun(@times,o1.b,o2.b) + ...
    bsxfun(@times,o1.c,o2.c) + bsxfun(@times,o1.d,o2.d)); %

  % consider inversion
  if ~ignoreInv, d = d .* ~bsxfun(@xor,o1.i,o2.i); end

  % take the maximum over all symmetric equivalent
  d = reshape(max(max(d,[],1),[],ndims(d)),s);

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
