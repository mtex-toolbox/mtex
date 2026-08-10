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
% See also
%  

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

% setup interpolation method
F = scatteredInterpolant;
% (:) so that a gridded source works too - ebsd.pos is a matrix there, and
% scatteredInterpolant wants numpoints-by-ndim
F.Points = [pos.x(:),pos.y(:)];
F.Method = 'nearest';
F.ExtrapolationMethod = 'none';

F.Values = (1:numel(ebsd.id)).';
idNearest = F(newPos.x,newPos.y);
isIndexed = ~isnan(idNearest);
idNearest = idNearest(isIndexed);

ebsdNew.phaseId = zeros(size(newPos));
ebsdNew.rotations = rotation.nan(size(newPos));

ebsdNew.phaseId(isIndexed) = reshape(ebsd.phaseId(idNearest),[],1);
ebsdNew.rotations(isIndexed) = ebsd.rotations(idNearest);

% copy properties
for fn = fieldnames(ebsd.prop).'
  
  if isnumeric(ebsd.prop.(char(fn))) || islogical(ebsd.prop.(char(fn)))
    ebsdNew.prop.(char(fn)) = nan(size(newPos));
  else
    ebsdNew.prop.(char(fn)) = ebsd.prop.(char(fn)).nan(size(newPos));
  end
  ebsdNew.prop.(char(fn))(isIndexed) = ebsd.prop.(char(fn))(idNearest);
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
