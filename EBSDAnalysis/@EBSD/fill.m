function ebsd = fill(ebsd,varargin)
% fill EBSD data by nearest neighbour
%
% Syntax
%   ebsd_filled = fill(ebsd)
%   ebsd_filled = fill(ebsd,grains)
%
% Input
%  ebsd - @EBSD
%  grains - @grain2d
%
% Options
%  extrapolate - extrapolate up the the outer boundaries
%

if ~(isa(ebsd,'EBSDsquare') || isa(ebsd,'EBSDhex')), ebsd = ebsd.gridify; end

% the values to be filled
nanId = isnan(ebsd.phaseId);

if check_option(varargin,'extrapolate')
  opt = 'nearest';
else
  opt = 'none';
end

F = scatteredInterpolant([ebsd.prop.x(~nanId),ebsd.prop.y(~nanId)],...
  find(~nanId),'nearest',opt); 

newId = F(ebsd.prop.x(nanId),ebsd.prop.y(nanId));

nanId(nanId) = ~isnan(newId);
newId(isnan(newId)) = [];

% interpolate phaseId
ebsd.phaseId(nanId) = ebsd.phaseId(newId);
ebsd.rotations(nanId) = ebsd.rotations(newId);
  
% interpolate grainId
try
  ebsd.prop.grainId(nanId) = ebsd.prop.grainId(newId);
end
  
grains = getClass(varargin,'grain2d',[]);
if isempty(grains), return; end

grains = grains(ismember(grains.id,unique(ebsd.grainId)));

nanId = find(nanId);

% check for whether the pixels are within certain grains
isInside = checkInside(grains,ebsd.subSet(nanId));

% set phase to not indexed if not inside any grain
ebsd.phaseId(nanId(~any(isInside,2))) = 1;
ebsd.grainId(nanId(~any(isInside,2))) = 0;

% the values to be filled
[ebsdId,hostId] = find(isInside);

wrongGrainId = ebsd.grainId(nanId(ebsdId)) ~= grains.id(hostId);

ebsd.phaseId(nanId(ebsdId)) = grains.phaseId(hostId);
ebsd.grainId(nanId(ebsdId)) = grains.id(hostId);
ebsd.rotations(nanId(ebsdId(wrongGrainId))) = grains.meanRotation(hostId(wrongGrainId));
  
end
