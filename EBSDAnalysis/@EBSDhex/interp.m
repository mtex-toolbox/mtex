function ebsdNew = interp(ebsd,xNew,yNew,varargin)
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
% See also
%  

% ensure column vectors
xNew = xNew(:); yNew = yNew(:);

% find nearest neighbour first
idNearest = ebsd.xy2ind(xNew,yNew);

% check nearest is inside the box
isIndexed = ~isnan(idNearest);

% check nearest is indexed
isIndexed(isIndexed) = ebsd.isIndexed(idNearest(isIndexed));
idNearest = idNearest(isIndexed);

% nearest neighbor interpolation first
rot = rotation.nan(size(xNew));
rot(isIndexed) = ebsd.rotations(idNearest);

phaseId = ones(size(xNew));
phaseId(isIndexed) = ebsd.phaseId(idNearest);

% copy properties
prop = struct('x',xNew,'y',yNew);
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end

  if isnumeric(ebsd.prop.(char(fn))) || islogical(ebsd.prop.(char(fn)))
    prop.(char(fn)) = nan(size(xNew));
  else
    prop.(char(fn)) = ebsd.prop.(char(fn)).nan(size(xNew));
  end
  prop.(char(fn))(isIndexed) = ebsd.prop.(char(fn))(idNearest);
end

ebsdNew = EBSD(rot,phaseId,ebsd.CSList,prop);
ebsdNew.phaseMap = ebsd.phaseMap;
ebsdNew.phaseId = phaseId(:);
ebsdNew.CSList = ebsd.CSList;

end