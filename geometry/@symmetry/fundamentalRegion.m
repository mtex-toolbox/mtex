function  [oR,dcs,nSym] = fundamentalRegion(cs,varargin)
% fundamental region in orientation space for a (pair) of symmetries 
%
% Syntax
%   oR = fundamentalRegion(cs)
%   oR = fundamentalRegion(cs1,cs2)
%   [oR,dcs,nSym] = fundamentalRegion(cs1,cs2)
%
% Input
%  cs,cs1,cs2 - @symmetry
%
% Output
%  oR - @orientationRegion
%  dc - @symmetry intersection between cs1 and cs2 
%  nSym - number of disjoined symmetry elements in cs2 * cs1
%
% Options
%  antipodal  - grain exchange symmetry, i.e.,  mori == inv(mori)
%  LaueGroup  - consider only Laue groups (default)
%  pointGroup - consider point groups
%

% The region is determined by the two rotation groups and the flags below,
% and computing it is a fifth of a plotSection - so keep the last few. The
% key is built from the rotations, the axes and the plotting convention
% themselves, never from the point group id: two symmetries of the same id
% can be aligned differently, which is exactly how the inverse pole figure
% color key cache went stale.
persistent cache

if nargin >= 2 && (isa(varargin{1},'symmetry')||isa(varargin{1},'rotation'))
  csOther = varargin{1}; opt = varargin(2:end);
else
  csOther = []; opt = varargin;
end

% every option goes into the key verbatim rather than a list of the ones
% known to matter here - fundamentalSector and orientationRegion read
% options of their own ('complete', 'upper', 'angle', ...) and a whitelist
% would have to track them. Options that are objects are not hashed, those
% calls simply do not cache
key = [symKey(cs); NaN; symKey(csOther)];
for k = 1:numel(opt)
  o = opt{k};
  if ischar(o) || isstring(o)
    key = [key; NaN; 1; double(char(o)).']; %#ok<AGROW>
  elseif isnumeric(o) || islogical(o)
    key = [key; NaN; 2; double(o(:))]; %#ok<AGROW>
  elseif isa(o,'symmetry') || isa(o,'rotation')
    % the symmetries are passed along by the callers, e.g. the ODF section
    % classes hand their whole option list down
    key = [key; NaN; 3; symKey(o)]; %#ok<AGROW>
  elseif isa(o,'plottingConvention')
    % fundamentalSector reads one of these
    q = quaternion(o.rot);
    key = [key; NaN; 4; q.a; q.b; q.c; q.d]; %#ok<AGROW>
  else
    key = []; break
  end
end

if ~isempty(key)

  hit = find(arrayfun(@(c) isequaln(c.key,key),cache),1);

  % a hit without the common symmetries stored is one from a call that
  % never computed them - let it run again and raise as it did back then
  if ~isempty(hit) && (nargout < 2 || ~isempty(cache(hit).dcs))
    oR = cache(hit).oR;
    if nargout > 1
      dcs = cache(hit).dcs.copy; % a symmetry is a handle - never hand out
      nSym = cache(hit).nSym;    % the cached one, a caller may change it
    end
    return
  end
end

if ~check_option(varargin,'pointGroup'), cs = cs.properGroup; end

rot = cs.rot;
N0 = quaternion;
if nargin >= 2 && (isa(varargin{1},'symmetry')||isa(varargin{1},'rotation'))

  cs2 = varargin{1};
  varargin(1) = [];
  % in the usual setting we don't care about reflections
  if ~check_option(varargin,'pointGroup'), cs2 = cs2.properGroup; end
  
  rot = cs2 * rot;   
  rot = rot(~rot.isImproper);
  rot = unique(quaternion(rot),'antipodal');
  
  if ~check_option(varargin,'ignoreCommonSymmetries')
    dcs = disjoint(cs,cs2);
    
    if check_option(varargin,'antipodal')
      dcs = dcs.Laue; 
    else
      dcs = dcs.properGroup;
    end
      
    sR = dcs.fundamentalSector(varargin{:});
        
    N0 = rotation.byAxisAngle(sR.N,pi-1e-5);
  end
else
  rot = rot(~rot.isImproper);
  rot = quaternion(unique(rot));
  dcs = cs.properSubGroup;
  if check_option(varargin,'antipodal'), dcs = dcs.Laue; end
  cs2 = {};
end
nSym = length(rot);

% take +- minimal angles for each axis
rot(abs(rot.angle)<1e-3) = [];
axes = rot.axis;

[axes,~,c] = unique(axes,'tolerance',1e-3);
angles = zeros(size(axes));

for i = 1:length(axes)
  angles(i) = min(angle(rot(c==i)));
end

N = [axes;-axes];
if ~isempty(N)
  Nq = axis2quat(N,[angles/2;pi-angles/2]);
else
  Nq = quaternion;
end

oR = orientationRegion([Nq(:).',N0(:).'],cs,cs2,varargin{:});

if ~isempty(key)
  entry = struct('key',key,'oR',oR,'dcs',[],'nSym',nSym);
  if exist('dcs','var'), entry.dcs = dcs.copy; end
  cache = [entry,cache];
  if numel(cache) > 12, cache(13:end) = []; end
end

end

% -------------------------------------------------------------------------

function key = symKey(cs)
% the identity of a symmetry as far as the fundamental region is concerned:
% its rotations, the lattice they are given in, and everything that would
% be visible on the region handed back - a name, a plotting convention

if isempty(cs), key = []; return; end

% the second argument may also be a plain list of rotations
if isa(cs,'symmetry'), q = quaternion(cs.rot); else, q = quaternion(cs); end
key = [double(isa(cs,'crystalSymmetry')); q.a(:); q.b(:); q.c(:); q.d(:)];

if ~isa(cs,'symmetry'), return; end

% only a crystal symmetry has a lattice
if isa(cs,'crystalSymmetry')
  a = cs.axes;
  key = [key; a.x(:); a.y(:); a.z(:)];
end

% only frames carry conventions, and the region is handed back carrying one
pC = quaternion(cs.how2plot.rot);
key = [key; pC.a; pC.b; pC.c; pC.d];

if isprop(cs,'mineral'), key = [key; double(char(cs.mineral)).']; end

end
