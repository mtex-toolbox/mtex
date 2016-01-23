function ebsd = fill(ebsd,varargin)
% fill spatial EBSD data
%
% The function |fill| changes the values of phaseId and graindId from NaN
% to a the value of its nearest neighbours. In case an grain object is
% specified as a second argument, only pixels that are entirely inside a
% grains will to associated to this grain. 
%
% Syntax
%
%   ebsd = fill(ebsd)
%   ebsd = fill(ebsd,grains)
%
% Input
%  ebsd - @EBSD
%
% Example

grains = getClass(varargin,'grain2d',[]);
if isempty(grains)

  % the values to be filled
  nanId = isnan(ebsd.phaseId);
  
  F = TriScatteredInterp([ebsd.prop.x(~nanId),ebsd.prop.y(~nanId)],...
    find(~nanId),'nearest'); %#ok<DTRIINT>
  newId = fix(F(ebsd.prop.x(nanId),ebsd.prop.y(nanId)));

  % interpolate phaseId
  ebsd.phaseId(nanId) = ebsd.phaseId(newId);

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
  
end

end
