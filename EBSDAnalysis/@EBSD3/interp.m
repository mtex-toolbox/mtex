function ebsdNew = interp(ebsd3, newPos, varargin)
% interpolate at arbitrary points newPos
%
% Syntax
%   ebsdNew = interp(ebsd,newPos)
%
%   ebsdNew = interp(ebsd,newPos,'method','invDist')
%
% Input
%  ebsd - @EBSD3
%  newPos - new x,y coordinates (vector3d)
%
% Output
%  ebsdNew - @EBSD with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
%
% See also
%  

ebsdNew = ebsd3;
ebsdNew.CSList = ebsd3.CSList;
ebsdNew.pos = newPos;
ebsdNew.id = (1:length(newPos)).';

% setup interpolation method
F = scatteredInterpolant;
F.Points = ebsd3.pos.xyz;
F.Method = 'nearest';
F.ExtrapolationMethod = 'none';

F.Values = (1:length(ebsd3)).';
idNearest = F(newPos.x,newPos.y,newPos.z);
isIndexed = ~isnan(idNearest);
idNearest = idNearest(isIndexed);

ebsdNew.phaseId = zeros(size(newPos));
ebsdNew.rotations = rotation.nan(size(newPos));

ebsdNew.phaseId(isIndexed) = reshape(ebsd3.phaseId(idNearest),[],1);
ebsdNew.rotations(isIndexed) = ebsd3.rotations(idNearest);

% copy properties
for fn = fieldnames(ebsd3.prop).'
  
  if isnumeric(ebsd3.prop.(char(fn))) || islogical(ebsd3.prop.(char(fn)))
    ebsdNew.prop.(char(fn)) = nan(size(newPos));
  else
    ebsdNew.prop.(char(fn)) = ebsd3.prop.(char(fn)).nan(size(newPos));
  end
  ebsdNew.prop.(char(fn))(isIndexed) = ebsd3.prop.(char(fn))(idNearest);
end

