function ebsdNew = interp(ebsd3, newPos, varargin)
% interpolate at arbitrary points newPos
%
% Syntax
%   ebsdNew = interp(ebsd,newPos)
%
%   ebsdNew = interp(ebsd,newPos,'method','invDist')
%
% Input
%  ebsd - @EBSD3square
%  newPos - new x,y coordinates (vector3d)
%
% Output
%  ebsdNew - @EBSD3square with coordinates (xNew,yNew)
%
% Options
%  method - 'invDist', 'nearest'
%
% See also
%  

% new size
sizeNew = size(newPos);

% nearest neighbor interpolation first
F = griddedInterpolant(ebsd3.pos.x,ebsd3.pos.y,ebsd3.pos.z,ebsd3.id,"nearest","none");

idNew = F(newPos.x,newPos.y,newPos.z);
isIndexed = ~isnan(idNew);
idNew = idNew(isIndexed);
rot = rotation.nan(sizeNew);
rot(isIndexed) = ebsd3.rotations(idNew);

phaseId = ones(prod(sizeNew),1);
phaseId(isIndexed) = ebsd3.phaseId(idNew);

% copy properties
prop = struct();
for fn = fieldnames(ebsd3.prop).'
  
  if isnumeric(ebsd3.prop.(char(fn))) || islogical(ebsd3.prop.(char(fn)))
    prop.(char(fn)) = nan(sizeNew);
  else
    prop.(char(fn)) = ebsd3.prop.(char(fn)).nan(sizeNew);
  end
  prop.(char(fn))(isIndexed) = ebsd3.prop.(char(fn))(idNew);
end

switch nnz(sizeNew>1)
  case 1
    ebsdNew = EBSD(newPos,rot,phaseId,ebsd3.CSList,prop,'phaseMap',ebsd3.phaseMap);
  case 2
    ebsdNew = EBSDsquare(newPos,rot,phaseId,ebsd3.phaseMap,ebsd3.CSList,'prop',prop,'opt',ebsd3.opt);
  case 3
    ebsdNew = EBSD3square(newPos,rot,phaseId,ebsd3.phaseMap,ebsd3.CSList,[1 1 1],prop);
end

end