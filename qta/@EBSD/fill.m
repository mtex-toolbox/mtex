function ebsd = fill(ebsd,cube,dx)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
%% Input
% ebsd - @EBSD
% cube - a cube with extends [xmin xmax ymin ymax zmin zmax]
% dx   - stepsize
%
%% Example
%  ebsd_filled = fill(ebsd,extend(ebsd),.6)
%

%% extract spatial coordinates

dim = nnz(isfield(ebsd.options,{'x','y','z'}));

if dim == 2
  X = get(ebsd,'xy');  
elseif dim == 3
  X = get(ebsd,'xyz');
end

if numel(dx) == 1
  dx(1:3) = dx;
end

%% generate regular grid and interpolate

% setup interpolation object
F = TriScatteredInterp(X,(1:size(X,1)).','nearest');

% interpolate
if dim  == 2
  [xi,yi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4));
  ebsd.options.x = xi(:);
  ebsd.options.y = yi(:);
  ci = fix(F(xi,yi));
elseif dim == 3
  [xi,yi,zi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4),cube(5):dx(3):cube(6));
  ebsd.options.x = xi(:);
  ebsd.options.y = yi(:);
  ebsd.options.z = zi(:);
  ci = fix(F(xi,yi,zi));
end

%% fill ebsd variable

ebsd.rotations = reshape(ebsd.rotations(ci),[],1);
ebsd.phase = reshape(ebsd.phase(ci),[],1);

for fn = fieldnames(ebsd.options).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  ebsd.options.(char(fn)) = ebsd.options.(char(fn))(ci);
end

X = [ebsd.options.x(:),ebsd.options.y(:)];
if isfield(ebsd.options,'z')
  X = [X ebsd.options.z(:)];
end

ebsd.unitCell = calcUnitCell(X);

