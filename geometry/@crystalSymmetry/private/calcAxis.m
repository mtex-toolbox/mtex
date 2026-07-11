function abc  = calcAxis(id,axisLength,angle,varargin)
% calculate the axis a, b, c of the crystal coordinate system with respect
% to the euclidean reference frame
%
% Input
%  axisLength - [a,b,c]
%  angle - [alpha,beta,gamma]
%
% Options
%  X||a, X||a*, Z||c - alignment of the cartesian coordinate system to the crystal coordinate system
%
% Output
%  abc - @vector3d
%

% get axis length
if axisLength(3) == 0, axisLength(3) = max(axisLength);end
if axisLength(3) == 0, axisLength(3) = 1;end

if axisLength(1) == 0, axisLength(1) = axisLength(2);end
if axisLength(2) == 0, axisLength(2) = axisLength(1);end
if axisLength(2) == 0
  axisLength(2) = axisLength(3);
  axisLength(1) = axisLength(3);
end

% get angles
if angle(1) == 0
  if angle(2) == 0, angle(2) = pi/2;end
  angle(1) = pi - angle(2);
end
if angle(2) == 0,  angle(2) = pi - angle(1);end
if angle(3) == 0, angle(3) = pi/2;end

pg = symmetry.pointGroups(id);

% check for correct lattice parameters
if ~check_option(varargin,'force')
  switch pg.lattice
    case 'triclinic'
    case 'monoclinic'
      notRot = 1:3; notRot(floor(id/3))=[];
      assert(all(isappr(angle(notRot),pi/2,1e-5)),'For monoclinic lattices the angles with the symmetry axis have to be 90 degree');
    case 'orthorhombic'
    case 'trigonal'
      assert(axisLength(1)== axisLength(2),'For trigonal lattices a and b must be equal!');
    case 'hexagonal'
      assert(axisLength(1)== axisLength(2),'For hexagonal lattices a and b must be equal!');
    case 'tetragonal'
      assert(axisLength(1)== axisLength(2),'For tetragonal lattices a and b must be equal!');
    case 'cubic'
      assert(all(axisLength(1)== axisLength),'For cubic lattices a, b and c must be equal!');
    case 'icosahedral'
      assert(all(axisLength(1)== axisLength),'For icosahedral lattices a, b and c must be equal!');
  end
end

% start by defining a reference coordinate system
% which uses the (default) convention
% * X || a*
% * Z || c
switch pg.lattice
  case {'trigonal','hexagonal'}
    abc = axisLength(:).' .* vector3d([sqrt(0.75) 0 0],[-0.5 1 0],[0 0 1]);

  case {'orthorhombic','cubic'}
    abc = axisLength(:) .* vector3d.byXYZ(eye(3));

  otherwise

    cangle = cos(angle);
    sangle = sin(angle(1));
    abc = axisLength(:).' .* vector3d(...
      [sqrt(1+2*prod(cangle) - sum(cangle.^2))/sangle,0,0],...
      [(cangle(3) - cangle(1) * cangle(2))/sangle,sangle,0],...
      [cangle(2),cangle(1),1]);

end

% extract alignment options
% restrict to strings
alignOpt = varargin(cellfun(@(s) ischar(s),varargin));

% nothing to do - abc is already in the default X||a*, Z||c convention
if isempty(alignOpt), return; end

% compute a* b* c*
% (the direction of the reciprocal axes only depends on the physical
% lattice, not on the coordinate frame abc happens to be expressed in,
% so a single cross product formula works for all lattice types)
abcStar = cross(abc([2 3 1]),abc([3 1 2]));

% which arguments should be flipped
flipthem = ~cellfun('isempty',regexpi(alignOpt,'\|\|[xyz]'));

% now flip them
alignOpt(flipthem) = cellfun(@(a) [a(end:-1:end-2) a(1:end-3)],alignOpt(flipthem),'UniformOutput',false);

% if nothing or only Y is specified set Z||c
if ~any(cell2mat(regexpi(alignOpt,'z\|\|'))) && ...
    nnz(cell2mat(regexpi(alignOpt,'[xy]\|\|')))<=1

  p = '[xy]\|\|[abc]'; % check for something like x||a
  if all(cellfun(@isempty,regexpi(alignOpt,['(?!' p '\*)' p])))
    alignOpt = [alignOpt,{'Z||c'}];
  else
    alignOpt = [alignOpt,{'Z||c*'}];
  end
end

% extract alignment for x, y, z directions
axes = ['X','Y','Z'];
alignment = cell(1,3);

% extract alignment for each axis
for ia = 1:3

  al = regexpi(alignOpt,[axes(ia) '\|\|([abcdm]*\*?)'],'tokens');
  al = [al{:}];
  alignment{ia} = char(al{:});

end

% setup new x, y, z directions
xyzNew = vector3d.zeros(1,3);
for ia = 1:3

  switch lower(alignment{ia})

    case 'a'
      xyzNew(ia) = abc(1);
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = abcStar(3);
      end
    case 'b'
      xyzNew(ia) = abc(2);
    case 'c'
      xyzNew(ia) = abc(3);
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = abcStar(1);
      end
    case 'a*'
      xyzNew(ia) = abcStar(1);
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = abc(3);
      end
    case 'b*'
      xyzNew(ia) = abcStar(2);
    case 'c*'
      xyzNew(ia) = abcStar(3);
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = abc(1);
      end
    case 'm'
      xyzNew(ia) = sum(abc(1:2));
    case 'd'
      xyzNew(ia) = sum(abc);
  end
end

% set any missing axis as the cross product of the two others
for ia = 1:3
  if norm(xyzNew(ia)) < 1e-6
    xyzNew(ia) = cross(xyzNew(mod(ia,3)+1),xyzNew(mod(ia+1,3)+1));
  end
end

% set up the transformation matrix
M = double(normalize(xyzNew)).';

% check for orthogonality
if norm(M^(-1) - M') > 1e-6
  error('Bad alignment options! Non Euclidean reference frame!')
end

if det(M) < 0, M(2,:) = -M(2,:);end

% now compute the new a, b, c axes
abc = vector3d(M * double(abc));

if check_option(varargin,'rotAxes')
  abc = get_option(varargin,'rotAxes') * abc;
end
