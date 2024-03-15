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

ebsdNew = ebsd;
ebsdNew.CSList = ebsd.CSList;
ebsdNew.pos = newPos;
ebsdNew.id = (1:length(newPos)).';

% rotate everything to a plane
pos = ebsd.rot2Plane .* ebsd.pos;
newPos = ebsd.rot2Plane .* newPos;

% setup interpolation method
F = scatteredInterpolant;
F.Points = [pos.x,pos.y];
F.Method = 'nearest';
F.ExtrapolationMethod = 'none';

F.Values = (1:length(ebsd)).';
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
