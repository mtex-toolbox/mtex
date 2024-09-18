function ebsdNew = interp(ebsd,pos,varargin)
% interpolate at arbitrary points (x,y)
%
% Syntax
%   ebsdNew = interp(ebsd,xNew,yNew)
%
% Input
%  ebsd - @EBSDhex
%  xNew, yNew - new x,y coordinates
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  nearest - neares neighbor interpolation
%
% See also
%  

% ensure column vectors
pos = pos(:);

% find nearest neighbour first
idNearest = ebsd.xy2ind(pos.x,pos.y);

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

ebsdNew = EBSD(pos,rot,phaseId,ebsd.CSList,prop);
ebsdNew.phaseMap = ebsd.phaseMap;
ebsdNew.phaseId = phaseId(:);
ebsdNew.CSList = ebsd.CSList;

end