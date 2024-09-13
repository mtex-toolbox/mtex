function ebsd = updateUnitCell(ebsd,uc)
% this function should be called after the spatial coordinates of an EBSD
% data set have been modified

if nargin == 1 || isempty(uc)
  uc = calcUnitCell([ebsd.pos.x(:),ebsd.pos.y(:)]); 
end

if ~isa(uc,'vector3d'), uc = vector3d(uc(:,1),uc(:,2),0); end

ebsd.unitCell = uc;

end