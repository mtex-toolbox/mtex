function cF = crystalSymmetry(varargin)
% the crystal reference frame of a phase, carrying its point group
%
% Since <crystalFrame.crystalFrame.html |crystalFrame|> carries the point
% group (ADR 0008), a crystal symmetry *is* a crystal frame - this is the
% constructor that names it the way crystallography does. It returns a
% @crystalFrame.
%
% Syntax
%   crystalSymmetry('cubic')
%   crystalSymmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase')
%   crystalSymmetry('O')
%   crystalSymmetry(cF)  % the trivial group carrying the crystalFrame cF
%   crystalSymmetry('LaueId',9)
%   crystalSymmetry('SpaceId',153)
%   rot = rotation.map(vector3d(1,1,1),vector3d.Z,vector3d(0,-1,1),vector3d.X)
%   crystalSymmetry('432','rotAxes',rot)
%
% Input
%  name  - Schoenflies or International notation of the point group
%  axes  - [a,b,c] - length of the crystallographic axes
%  angle - [alpha,beta,gamma] - angle between the axes
%
% Options
%  X||a*, Z||c - default alignment of the Cartesian to the crystal axes
%  X||a, Z||c* - other alignments
%  EDAX        - the alignment convention used by EDAX / TSL / OIM
%
% Output
%  cF - @crystalFrame
%
% See also
% crystalFrame specimenSymmetry symmetry

% this is for compatibility with using "strings" as input
try varargin = controllib.internal.util.hString2Char(varargin); catch, end

% the trivial group carrying a given crystalFrame
frameAdopted = nargin > 0 && isa(varargin{1},'crystalFrame');

% a specimen frame has no lattice, so it is not one a crystal group can be
% written in - its canonical basis would stand in for the crystal axes
if nargin > 0 && isa(varargin{1},'referenceFrame') && ~frameAdopted
  error('MTEX:wrongFrameClass',...
    ['A crystal symmetry needs a crystalFrame, not a ' class(varargin{1}) '.']);
end

if frameAdopted

  % the trivial group carrying that frame - its group-stripped sibling
  cF = stripSym(varargin{1});
  varargin(1) = [];
  id = 1;
  rot = rotation.id;

elseif nargin == 0

  id = 1;
  axes = [xvector,yvector,zvector];
  rot = rotation.id;

elseif isa(varargin{1},'quaternion')  % the group given by its elements

  rot = rotation(varargin{1});
  axes = getClass(varargin,'vector3d',[xvector,yvector,zvector]);

  if check_option(varargin,'pointId')
    id = get_option(varargin,'pointId');
  else
    id = symmetry.rot2pointId(rot,axes);
  end

else

  [id, varargin] = symmetry.extractPointId(varargin{:});

  % get axes length (a b c)
  if ~isempty(varargin) && isnumeric(varargin{1})
    abc = varargin{1};
    varargin(1) = [];
  else
    abc = [1,1,1];
  end

  % extract axes angles (alpha beta gamma)
  lattice = symmetry.pointGroups(id).lattice;
  angles = lattice.defaultAngles;

  if ~isempty(varargin) && isnumeric(varargin{1})
    angles = varargin{1};
    if any(angles>2*pi), angles = angles * degree; end
    varargin(1) = [];
  end

  % crystalFrame owns the axes computation including the alignment options
  cF = crystalFrame(abc,angles,varargin{:},'pointId',id);
  axes = cF.basis;

  % compute symmetry operations
  rot = getClass(varargin,'quaternion');
  if isempty(rot), rot = symmetry.calcQuat(id,axes); end

end

% axes given directly - wrap them into a frame
if ~exist('cF','var'), cF = crystalFrame(axes); end

% an adopted frame states its own group and must keep it
if ~frameAdopted, cF.sym = symmetry(id,rot); end

% the mineral doubles as the frame identity - an adopted frame donates its name
if frameAdopted
  mineral = get_option(varargin,'mineral',char(cF.name));
else
  mineral = get_option(varargin,'mineral','');
end
mineral = strtrim(regexprep(mineral,char(0),' '));
cF.mineral = mineral;
cF.color = get_option(varargin,'color','');
if ~frameAdopted, cF.name = mineral; end
askedColor = get_option(varargin,'color','');

if check_option(varargin,'density')
  cF.opt.density = get_option(varargin,'density','');
end

% the plotting convention, unless an adopted frame carries one
if ~frameAdopted || isempty(cF.how2plot)
  if id > 11 || id == 0
    cF.how2plot = plottingConvention(cF.cAxisRec,cF.aAxis);
  else
    cF.how2plot = plottingConvention(cF.cAxisRec,cF.bAxis);
  end
end

% the session instance of this frame - a file that lists two phases has two
% phases whatever their names and lattices, so an importer says 'noIntern'
if ~check_option(varargin,'noIntern')
  registered = referenceFrame.intern(cF);
  % colour is not in the key, and the registered instance keeps the one it
  % was first given: loading a second file must not restyle data already in
  % the workspace. A colour asked for explicitly still wins
  if registered ~= cF && ~isempty(askedColor), registered.color = askedColor; end
  cF = registered;
end

end
