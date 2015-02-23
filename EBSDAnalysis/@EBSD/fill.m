function ebsd = fill(ebsd)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
% Input
%  ebsd - @EBSD
%
% Example
%   ebsd_filled = fill(ebsd)
%

% setup interpolation object
F = TriScatteredInterp([ebsd.prop.x,ebsd.prop.y],(1:length(ebsd)).','nearest');

% generate regular grid
ext = ebsd.extend;
dx = ebsd.unitCell(1,1)-ebsd.unitCell(4,1);
dy = ebsd.unitCell(1,2)-ebsd.unitCell(2,2);
[xi,yi] = meshgrid(ext(1):dx:ext(2),ext(3):dy:ext(4));

% find nearest neigbour
ci = fix(F(xi,yi));

% fill ebsd variable
ebsd.id = (1:numel(xi)).';
ebsd.prop.x = xi(:);
ebsd.prop.y = yi(:);
ebsd.rotations = reshape(ebsd.rotations(ci),[],1);
ebsd.phaseId = reshape(ebsd.phaseId(ci),[],1);

for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  ebsd.prop.(char(fn)) = ebsd.prop.(char(fn))(ci);
end
