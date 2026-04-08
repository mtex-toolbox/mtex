function ebsdNew = interp(ebsd,pos,varargin)
% interpolate at arbitrary points (x,y)
%
% Syntax
%   ebsdNew = interp(ebsd,xNew,yNew)
%
% Input
%  ebsd - @EBSDhex
%  pos  - new pixel centers
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  nearest - nearest neighbor interpolation
%
% See also
%  

if ~isa(pos,'vector3d'), pos = vector3d(pos,varargin{1},0); end

% find nearest neighbor first
idNearest = ebsd.pos2ind(pos.x(:),pos.y(:));

% check nearest is inside the box
isIndexed = ~isnan(idNearest);

% check nearest is indexed
isIndexed(isIndexed) = ebsd.isIndexed(idNearest(isIndexed));
idNearest = idNearest(isIndexed);

% nearest neighbor interpolation first
rot = rotation.nan(size(pos));
rot(isIndexed) = ebsd.rotations(idNearest);

phaseId = ones(size(pos));
phaseId(isIndexed) = ebsd.phaseId(idNearest);

% copy properties
prop = struct();
for fn = fieldnames(ebsd.prop).'

  if isnumeric(ebsd.prop.(char(fn))) || islogical(ebsd.prop.(char(fn)))
    prop.(char(fn)) = nan(size(pos));
  else
    prop.(char(fn)) = ebsd.prop.(char(fn)).nan(size(pos));
  end
  prop.(char(fn))(isIndexed) = ebsd.prop.(char(fn))(idNearest);
end

if ismatrix(pos)  
  ebsdNew = EBSDsquare(pos,rot,phaseId,ebsd.phaseMap,ebsd.CSList,'prop',prop);
else
  ebsdNew = EBSD(pos,rot,phaseId,ebsd.CSList,prop,'phaseMap',ebsd.phaseMap);
end

end