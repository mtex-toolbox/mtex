function ebsd = fill(ebsd,cube,dx)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
%% Input
% ebsd  -  @EBSD
% cube  -  a cube with extends [xmin xmax ymin ymax zmin zmax]
% dx    -  stepsize
%
%% Example
% fill(ebsd,extend(ebsd),.6)
%

%% extract spatial coordinates
X = get(ebsd,'xyz');
if numel(dx) == 1
  dx(1:3) = dx;
end

%% generate regular grid and interpolate

% setup interpolation object
F = TriScatteredInterp(X,(1:size(X,1)).','nearest');

% interpolate
if size(X,2)  == 2
  [xi,yi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4));
  ebsd.options.x = xi(:);
  ebsd.options.y = yi(:);
  ci = fix(F(xi,yi));
else
  [xi,yi,zi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4),cube(5):dx(3):cube(6));
  ebsd.options.x = xi(:);
  ebsd.options.y = yi(:);
  ebsd.options.z = zi(:);
  ci = fix(F(xi,yi,zi));
end

%% fill ebsd variable

ebsd.rotations = ebsd.rotations(ci);
ebsd.phase = ebsd.phase(ci);

for fn = fieldnames(ebsd.options).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  ebsd.options.(char(fn)) = ebsd.options.(char(fn))(ci);
end