function ebsdNew = interp(ebsd, newPos, varargin)
% interpolate EBSD map at arbitrary points positions
%
% Syntax
%
%   ebsdNew = interp(ebsd,pos)
%
%   ebsdNew = interp(ebsd,xNew,yNew)
%
% Input
%  ebsd - @EBSD
%  pos  - @vector3d
%  xNew, yNew - new x,y coordinates
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Description
% A query point takes the data of the measurement it is nearest to, as long
% as it lies within that measurement's pixel - i.e. no further away than the
% circumradius of ebsd.unitCell. Everything else comes back notIndexed. The
% criterion is purely local, so it makes no assumption about the grid and
% works on a plain list, on a rotated or sheared grid and on a hexagonal one.
%
% See also
% EBSD/gridify EBSD/fill EBSD/lattice

if ~isa(newPos,'vector3d'), newPos = vector3d(newPos,varargin{1},0); end

% an @EBSD is a flat list, so normalise the query as the constructor would
newPos = newPos(:);

ebsdNew = ebsd;
ebsdNew.CSList = ebsd.CSList;
ebsdNew.pos = newPos;
ebsdNew.id = (1:length(newPos)).';

% rotate everything to a plane
pos = ebsd.rot2Plane .* ebsd.pos;
newPos = ebsd.rot2Plane .* newPos;

% nearest measurement for every query point, and how far away it is - not
% scatteredInterpolant, whose convex hull test drops border pixels; (:) so
% that a gridded source works too
[idNearest,dist] = knnsearch([pos.x(:),pos.y(:)],[newPos.x,newPos.y]);

% the circumradius of the unit cell, i.e. how far a pixel reaches at most
r = max(norm(ebsd.unitCell));
if isempty(r) || ~(r > 0)
  % no usable unit cell, so the nearest measurement is the best available answer
  r = inf;
end

isIndexed = dist <= r * (1 + 1e-10);
idNearest = idNearest(isIndexed);

% notIndexed, not 0 - phaseId 0 indexes neither CSList nor phaseMap. Only
% the gridded branch below used to be rescued from it, by the constructor
ebsdNew.phaseId = ones(size(newPos));
ebsdNew.rotations = rotation.nan(size(newPos));

ebsdNew.phaseId(isIndexed) = reshape(ebsd.phaseId(idNearest),[],1);
ebsdNew.rotations(isIndexed) = ebsd.rotations(idNearest);

% copy properties
for fn = fieldnames(ebsd.prop).'

  p = ebsd.prop.(char(fn));

  % a multi channel property is indexed by row and keeps its columns, see dynProp
  if size(p,2) > 1 && size(p,1) == length(ebsd)

    if isnumeric(p) || islogical(p)
      q = nan(length(newPos),size(p,2));
    else
      q = p.nan(length(newPos),size(p,2));
    end
    q(isIndexed,:) = p(idNearest,:);

  else

    if isnumeric(p) || islogical(p)
      q = nan(size(newPos));
    else
      q = p.nan(size(newPos));
    end
    q(isIndexed) = p(idNearest);

  end

  ebsdNew.prop.(char(fn)) = q;

end

% interpolating at arbitrary positions yields a list, so rebuild through the
% constructor - subSet would drop the rows whose phaseId is NaN
if isa(ebsdNew,'EBSDgrid')
  out = EBSD(ebsdNew.pos, ebsdNew.rotations, ebsdNew.phaseId, ...
    ebsdNew.CSList, ebsdNew.prop, 'phaseMap', ebsdNew.phaseMap);
  out.unitCell = ebsdNew.unitCell;
  out.scanUnit = ebsdNew.scanUnit;
  out.opt      = ebsdNew.opt;
  out.N        = ebsdNew.N;
  ebsdNew      = out;
end
