function ebsd = fill(ebsd,varargin)
% fill EBSD data by nearest neighbor interpolation
%
% Syntax
%   ebsd_filled = fill(ebsd)
%   ebsd_filled = fill(ebsd,grains)
%
% Input
%  ebsd - @EBSD
%  grains - @grain2d if provided pixels at the boundary between grains are not filled
%
% Options
%  extrapolate - extrapolate up the the outer boundaries
%  gridify     - return a gridded map, as this used to do unconditionally
%
% Description
% The pixels to fill have to exist before they can be filled, which is what
% gridify used to be for - at the cost of turning a plain @EBSD into an
% @EBSDsquare. addLatticeSites materialises exactly the same set of sites on
% the virtual lattice instead, so the input's class is kept. Pass 'gridify'
% for the old behaviour.

% TODO: this will not work for maps not in the xy plane


if ~isa(ebsd,'EBSDgrid')
  if check_option(varargin,'gridify')
    ebsd = ebsd.gridify;
  else
    ebsd = addLatticeSites(ebsd);
  end
end

% the values to be filled
nanId = isnan(ebsd.rotations);

if check_option(varargin,'extrapolate')
  opt = 'nearest';
else
  opt = 'none';
end

F = scatteredInterpolant(double([ebsd.pos.x(~nanId),ebsd.pos.y(~nanId)]),...
  find(~nanId),'nearest',opt); 

newId = F(double(ebsd.pos.x(nanId)),double(ebsd.pos.y(nanId)));

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
