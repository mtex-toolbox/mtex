function ebsd = fill(ebsd,varargin)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
% Syntax
%   ebsd_filled = fill(ebsd)
%
% Input
%  ebsd - @EBSD
%

if ~(isa(ebsd,'EBSDsquare') || isa(ebsd,'EBSDhex')), ebsd = ebsd.gridify; end

grains = getClass(varargin,'grain2d',[]);
if isempty(grains)

  % the values to be filled
  nanId = isnan(ebsd.phaseId);
  
  F = TriScatteredInterp([ebsd.prop.x(~nanId),ebsd.prop.y(~nanId)],...
    find(~nanId),'nearest'); %#ok<DTRIINT>
  newId = fix(F(ebsd.prop.x(nanId),ebsd.prop.y(nanId)));

  % interpolate phaseId
  ebsd.phaseId(nanId) = ebsd.phaseId(newId);
  ebsd.rotations(nanId) = ebsd.rotations(newId);
  
  % interpolate grainId
  try
    ebsd.prop.grainId(nanId) = ebsd.prop.grainId(newId);
  end
  
else % check for whether the pixels are within certain grains

  % the values to be filled
  nanId = find(isnan(ebsd.phaseId));

  isInside = grains.checkInside(ebsd.subSet(nanId));
  
  [ebsdId,hostId] = find(isInside);
  
  ebsd.grainId(nanId(ebsdId)) = grains.id(hostId);
  ebsd.phaseId(nanId(ebsdId)) = grains.phaseId(hostId);
  
  ebsd.rotations(nanId(ebsdId)) = grains.meanRotation(hostId);
  
end

end
