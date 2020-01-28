function abc  = calcAxis(id,axisLength,angle,varargin)
% calculate the axis a, b, c of the crystal coordinate system with respect
% to the euclidean reference frame
%
% Input
%  axisLength - [a,b,c]
%  angle - [alpha,beta,gamma]
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
      assert(all(isappr(angle(notRot),pi/2)),'For monoclinic lattices the angles with the symmetry axis have to be 90 degree');
    case 'orthothombic'
    case 'trigonal'
      assert(axisLength(1)== axisLength(2),'For trigonal lattices a and b must be equal!');
    case 'hexagonal'
      assert(axisLength(1)== axisLength(2),'For hexagonal lattices a and b must be equal!');
    case 'tetragonal'
      assert(axisLength(1)== axisLength(2),'For tetragonal lattices a and b must be equal!');
    case 'cubic'
      assert(all(axisLength(1)== axisLength),'For cubic lattices a, b and c must be equal!');
  end
end

% start be defining a reference coordinate system
% which uses the convention
% * X || a
% * Z || c*
a = xvector;
b = cos(angle(3)) * xvector + sin(angle(3)) * yvector;
c = cos(angle(2)) * xvector + ...
  (cos(angle(1)) - cos(angle(2)) * cos(angle(3)))/sin(angle(3)) * yvector +...
  sqrt(1+2*prod(cos(angle)) - sum(cos(angle).^2))/sin(angle(3)) * zvector;

% compute a* b* c*

astar = normalize(cross(b,c));
bstar = normalize(cross(c,a));
cstar = normalize(cross(a,b));


% extract alignment options
% restrict to strings
alignOpt = varargin(cellfun(@(s) ischar(s),varargin));

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
xyzNew = vector3d(zeros(3));
for ia = 1:3
  
  switch lower(alignment{ia})
 
    case 'a'
      xyzNew(ia) = a;
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = cstar;
      end
    case 'b'
      xyzNew(ia) = b;
    case 'c'
      xyzNew(ia) = c;
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = astar;
      end
    case 'a*'
      xyzNew(ia) = astar;
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = c;
      end
    case 'b*'
      xyzNew(ia) = bstar;
    case 'c*'
      xyzNew(ia) = cstar;
      if rem(ia,2) && isempty(alignment{4-ia}) && isempty(alignment{2})
        xyzNew(4-ia) = a;
      end
    case 'm'
      xyzNew(ia) = a+b;
    case 'd'
      xyzNew(ia) = a+b+c;
  end
end
  
% set any missing axis as the cross product of the two others
for ia = 1:3
  if norm(xyzNew(ia)) < 1e-6
    xyzNew(ia) = cross(xyzNew(mod(ia,3)+1),xyzNew(mod(ia+1,3)+1));
  end
end

% set up the transformation matrix
M = reshape(double(normalize(xyzNew)),3,3);

% check for orthogonality
if norm(M^(-1) - M') > 1e-6
  error('Bad alignment options! Non Euclidean reference frame!')
end

if det(M) < 0, M(2,:) = -M(2,:);end

% now compute the new a, b, c axes
abc = vector3d((M * reshape(double(normalize([a,b,c])),3,3).')) .* axisLength(:).';

if check_option(varargin,'rotAxes')
  abc = get_option(varargin,'rotAxes') * abc;
end
