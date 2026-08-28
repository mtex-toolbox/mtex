function m = Miller(varargin)
% crystal directions and lattice planes
%
% A crystal direction is a <vector3d.vector3d.html vector3d> written in a
% <crystalFrame.crystalFrame.html crystalFrame>: it has the Miller indices
% hkl and uvw, a d-spacing, and where that frame carries a point group it
% stands for its whole symmetrically equivalent set. Internally it is stored
% in Euclidean coordinates.
%
% Syntax
%   m = Miller(h,k,l,cs)
%   m = Miller(h,k,i,l,cs)
%   m = Miller(u,v,w,cs,'uvw')
%   m = Miller(U,V,T,W,cs,'UVTW')
%   m = Miller({h1 k1 l1},{h2 k2 l2},{h3 k3 l3},cs) % list of indices
%   m = Miller('(hkl)',cs)   % one lattice plane
%   m = Miller('{hkl}',cs)   % all planes symmetrically equivalent to it
%   m = Miller('[uvw]',cs)   % one crystal direction
%   m = Miller('<uvw>',cs)   % all directions symmetrically equivalent to it
%   m = Miller('[uvw]\[uvw],cs)
%   m = Miller('(hkl)\(hkl),cs)
%   m = Miller(x,cs)
%
% Input
%  h,k,l   - three digit reciprocal coordinates
%  h,k,i,l - four digit reciprocal coordinates
%  u,v,w   - three digit direct coordinates
%  U,V,T,W - four digit direct coordinates - Weber indices
%  x       - @vector3d
%  cs      - @crystalFrame
%
% Output
%  m - @vector3d with the indices of cs
%
% See also
% CrystalDirections CrystalOperations CrystalReferenceSystem
% CrystalSymmetries FundamentalSector vector3d/vector3d
% isCrystalDirection crystalSymmetry

% an empty crystal direction
if nargin == 0, m = vector3d; return; end

% a direction given in Euclidean coordinates keeps its components and is
% restated in the crystal frame; anything else is built from its indices.
% Every one of them comes back a plain vector3d, and the components go
% through the constructor - a vector3d answers a subscripted assignment
% with one output, so writing x, y and z from outside would leave the
% object empty.
fr = getClass(varargin,'crystalFrame',[]);

if isa(varargin{1},'vector3d')

  [x,y,z] = double(varargin{1});
  m = vector3d(x,y,z);
  m.opt = varargin{1}.opt;
  m.antipodal = varargin{1}.antipodal;

  % a direction already written in a crystal frame keeps it
  if isempty(fr), fr = varargin{1}.framePrivate; end

elseif isa(varargin{1},'referenceFrame') && nargin > 3

  m = vector3d(varargin{2},varargin{3},varargin{4});

else
  m = vector3d;
end

assert(isa(fr,'crystalFrame'),...
  'No crystal symmetry has been specified when defining a crystal direction!');
m.framePrivate = fr;

% a crystal direction is written in indices, four of them where the lattice
% asks for it - a direction that has indices already keeps its own
if isa(varargin{1},'vector3d') && varargin{1}.dispStyle ~= MillerConvention.xyz
  dS = varargin{1}.dispStyle;
elseif fr.lattice.isTriHex
  dS = MillerConvention.hkil;
else
  dS = MillerConvention.hkl;
end
m.dispStyle = get_flag(varargin,{'uvw','UVTW','hkl','hkil','xyz'},dS);

if ischar(varargin{1})

  [m,isSingle] = s2v(varargin{1},m);

  % (hkl) and [uvw] stand for themselves, so what they get is the frame with
  % no group in it - the lattice stays, the claim on the whole set goes
  if isSingle, m.framePrivate = stripSym(fr); end

elseif iscell(varargin{1}) && ~isempty(varargin{1}) % list of Miller indices

  ind = find(cellfun(@iscell,varargin));
  m = Miller(varargin{ind(1)}{:},varargin{:});
  for i = 2:numel(ind)
    mm = Miller(varargin{ind(i)}{:},varargin{:});
    m =  [m,mm];
  end

elseif isa(varargin{1},'double') && ~isempty(varargin{1}) % hkl and uvw

  % get hkls and uvw from input
  nparam = min([length(varargin),4,find(cellfun(@(x) ~isa(x,'double'),varargin),1)-1]);

  % check for right input
  if nparam < 3, error('You need at least 3 Miller indice!');end

  % check fourth coefficient is right
  if nparam==4 && all(abs(varargin{1} + varargin{2} + varargin{3}) > eps*10)
    if check_option(varargin,{'uvw','uvtw','direction'})
      warning(['Convention u+v+t=0 violated! I assume t = ',num2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
    else
      warning(['Convention h+k+i=0 violated! I assume i = ',num2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
    end
  end

  % set coordinates
  coord = reshape([varargin{1:nparam}],[],nparam);

  if check_option(varargin,{'uvw','uvtw','direction'})

    if nparam == 3 && ~check_option(varargin,'uvtw')
      m.uvw = coord;
    else
      m.UVTW = coord;
    end

  elseif check_option(varargin,'xyz')

    m = vector3d(coord(:,1),coord(:,2),coord(:,3));
    m.framePrivate = fr;
    m.dispStyle = 'xyz';

  else

    m.hkl = coord;

  end

end

% add antipodal symmetry ?
m.antipodal = m.antipodal | check_option(varargin,'antipodal');

end
