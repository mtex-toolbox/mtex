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
%  EDAX - use the alignment convention of EDAX / TSL / OIM
%
% Output
%  abc - @vector3d
%

% get axis length
axisLength = double(axisLength);
angle = double(angle);
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

  case {'orthorhombic','tetragonal','cubic'}

    % all angles are 90 degree, so the axes are the scaled coordinate axes
    abc = (axisLength(:) .* vector3d.byXYZ(eye(3))).';

  otherwise

    cangle = cos(angle);
    sangle = sin(angle(1));
    abc = axisLength(:).' .* vector3d(...
      [sqrt(1+2*prod(cangle) - sum(cangle.^2))/sangle,0,0],...
      [(cangle(3) - cangle(1) * cangle(2))/sangle,sangle,0],...
      [cangle(2),cangle(1),1]);

end

% vendor specific alignment conventions
varargin = expandVendorAlignment(pg,varargin);

% only the strings that name an alignment, not 'mineral','Quartz' and the like
alignOpt = varargin(cellfun(@(s) ischar(s) || isstring(s),varargin));
alignOpt = alignOpt(cellfun(@(s) contains(s,'||'),alignOpt));

% nothing to do - abc is already in the default X||a*, Z||c convention
if ~isempty(alignOpt)
  abc = alignAxes(pg,axisLength,abc,alignOpt);
end

if check_option(varargin,'rotAxes')
  abc = get_option(varargin,'rotAxes') * abc;
end

end

% =========================================================================
function abc = alignAxes(pg,axisLength,abc,alignOpt)
% express the axes in the reference frame the alignment options ask for
%
% abc arrives in the MTEX default, X||a* and Z||c.

alignment = parseAlignment(alignOpt);

% ---- the two standard setups ------------------------------------------
% for these the axes are simply written down, anything else falls through below
if isStandardSetup(alignment)
  switch pg.lattice

    case {'orthorhombic','tetragonal','cubic'}
      % the axes are orthogonal, so a*||a, b*||b, c*||c all give the reference frame
      return

    case {'trigonal','hexagonal'}
      if strcmpi(alignment{1},'a')
        % X||a, the EDAX / TSL setup: the reference frame turned by 30
        % degree about c, so that a rather than a* falls on x
        abc = axisLength(:).' .* vector3d([1 -0.5 0],[0 sqrt(0.75) 0],[0 0 1]);
      end
      % X||a* is the reference frame itself
      return

  end
end

% ---- the general construction -----------------------------------------
% monoclinic and triclinic, and any axis out of its usual place

% compute a* b* c*, one cross product formula for all lattice types
abcStar = cross(abc([2 3 1]),abc([3 1 2]));

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

% now compute the new a, b, c axes - slice the 3 x 3, the constructor cannot read it
xyz = M * double(abc);
abc = vector3d(xyz(1,:),xyz(2,:),xyz(3,:));

end

% =========================================================================
function alignment = parseAlignment(alignOpt)
% canonicalise the alignment options into what x, y and z are aligned with
%
% Output is a 1 x 3 cell of 'a','b','c','a*','b*','c*','m','d' or '', one
% per Cartesian axis.

% an option may be written either way round, x||a or a||x
flipthem = ~cellfun('isempty',regexpi(alignOpt,'\|\|[xyz]'));
alignOpt(flipthem) = cellfun(@(a) [a(end:-1:end-2) a(1:end-3)], ...
  alignOpt(flipthem),'UniformOutput',false);

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

axes = ['X','Y','Z'];
alignment = cell(1,3);
for ia = 1:3
  al = regexpi(alignOpt,[axes(ia) '\|\|([abcdm]*\*?)'],'tokens');
  al = [al{:}]; %#ok<AGROW>
  alignment{ia} = char(al{:});
end

end

% =========================================================================
function tf = isStandardSetup(alignment)
% x on a or a*, z on c or c*, y left to follow from them
%
% For a lattice whose axes are mutually orthogonal these four combinations
% all describe the same frame, and for a hexagonal or trigonal one they
% describe the only two frames anybody uses.

tf = any(strcmpi(alignment{1},{'a','a*'})) && isempty(alignment{2}) && ...
  any(strcmpi(alignment{3},{'c','c*'}));

end

% =========================================================================
function opt = expandVendorAlignment(pg,opt)
% replace a vendor name by the alignment options it stands for
%
% EDAX / TSL / OIM align x with the a axis for all lattices where a and a*
% do not coincide within the a-b plane, i.e. triclinic, trigonal and
% hexagonal. For all remaining lattices their convention is identical to
% the MTEX default x || a*, z || c.

vendor = {'EDAX','TSL','OIM'};
if ~check_option(opt,vendor), return; end

opt = delete_option(opt,vendor);

% an explicitly given alignment always wins over the vendor default
isChar = cellfun(@(s) ischar(s),opt);
if any(~cellfun('isempty',regexpi(opt(isChar),'\|\|'))), return; end

switch pg.lattice
  case {'triclinic','trigonal','hexagonal'}
    opt = [opt,{'X||a'}];
end

end
