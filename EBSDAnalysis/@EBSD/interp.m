function ebsdNew = interp(ebsd, newPos, varargin)
% interpolate EBSD map at arbitrary points positions
%
% Syntax
%
%   ebsdNew = interp(ebsd,pos)
%
%   ebsdNew = interp(ebsd,xNew,yNew,'method','invDist')
%
% Input
%  ebsd - @EBSD
%  pos  - @vector3d
%  xNew, yNew - new x,y coordinates
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
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

% an @EBSD is a flat list, so normalise the query the same way the
% constructor normalises its input. interp assigns pos/phaseId/rotations
% directly and so bypasses that: interp(ebsd,x,y) with row vectors used to
% return an object whose pos and phaseId were 1 x n against an n x 1 id -
% self inconsistent, and length() then reported 1 rather than n. The
% documented row vector call in doc/EBSDAnalysis/EBSDInter.m hit exactly it.
newPos = newPos(:);

ebsdNew = ebsd;
ebsdNew.CSList = ebsd.CSList;
ebsdNew.pos = newPos;
ebsdNew.id = (1:length(newPos)).';

% rotate everything to a plane
pos = ebsd.rot2Plane .* ebsd.pos;
newPos = ebsd.rot2Plane .* newPos;

% nearest measurement for every query point, and how far away it is.
%
% NOT scatteredInterpolant with an ExtrapolationMethod of 'none': that
% decides "inside the map" by the convex hull of the source points, and a
% query sitting exactly ON that hull - which is what every border pixel does
% as soon as a map is resampled onto itself, e.g. by private/squarify - is
% put on either side of the test by floating point alone. Interpolating the
% forsterite map at its own positions lost 899 of its 245952 measurements
% that way, in a ragged pattern along the border, where the griddedInterpolant
% this replaced lost none. Being nearest to a pixel and lying inside it is a
% purely local criterion with no such edge, and knnsearch delivers it about
% twice as fast as scatteredInterpolant builds its triangulation.
%
% (:) so that a gridded source works too - ebsd.pos is a matrix there
[idNearest,dist] = knnsearch([pos.x(:),pos.y(:)],[newPos.x,newPos.y]);

% the circumradius of the unit cell: the largest distance from a pixel
% centre to a point still covered by that pixel, for a square, hexagonal or
% rotated cell alike. Slightly generous at the cell corners - the exact test
% would be point-in-polygon per cell - which errs towards keeping data
% rather than dropping it, the failure that mattered here.
r = max(norm(ebsd.unitCell));
if isempty(r) || ~(r > 0)
  % no usable unit cell, so nothing says how far a pixel reaches and the
  % nearest measurement is the best available answer. NaN lands here too -
  % calcUnitCell no longer produces one for a single scan line, but a cell
  % can still be handed in from anywhere
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

  % a multi channel property holds one ROW per measurement and k channels,
  % so it is indexed by row and keeps its columns - same test as dynProp's
  % isMultiColumn. On a gridded source an ordinary property is the (r x c)
  % matrix of the map, which length(ebsd) does not match, so it lands in the
  % else branch and idNearest indexes it linearly, as before
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

% Interpolating at arbitrary positions yields a LIST, whatever the source
% was, so the grid classes do not apply - they promise a matrix layout the
% query does not have. Callers wanting a grid back reshape or gridify, as
% private/squarify does.
%
% Rebuilt through the constructor rather than demoted with subSet: subSet
% routes through the copy constructor, which drops rows whose phaseId is
% NaN - and a gridded source has exactly those, at the notIndexed padding
% gridify added, so interpolating near them silently lost pixels (46 of
% 120000 when resampling a gridified ferrite map).
if isa(ebsdNew,'EBSDgrid')
  out = EBSD(ebsdNew.pos, ebsdNew.rotations, ebsdNew.phaseId, ...
    ebsdNew.CSList, ebsdNew.prop, 'phaseMap', ebsdNew.phaseMap);
  out.unitCell = ebsdNew.unitCell;
  out.scanUnit = ebsdNew.scanUnit;
  out.opt      = ebsdNew.opt;
  out.N        = ebsdNew.N;
  ebsdNew      = out;
end
