function ebsd = updateUnitCell(ebsd)
% this function should be called after the spatial coordinates of an EBSD
% data set have been modified

ebsd.unitCell = calcUnitCell([ebsd.prop.x(:),ebsd.prop.y(:)]);

end