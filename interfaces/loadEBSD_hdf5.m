function ebsd = loadEBSD_hdf5(fname,varargin)

%% Read rotations
as = h5read(fname, '/ebsd/rotations/a');
bs = h5read(fname, '/ebsd/rotations/b');
cs = h5read(fname, '/ebsd/rotations/c');
ds = h5read(fname, '/ebsd/rotations/d');

rotations = rotation(quaternion(as, bs, cs, ds));

%% Read phases
% Array 
phases = h5read(fname, '/ebsd/phases');

% Symmetry
info = h5info(fname, '/ebsd/cs');
cs = cell(numel(info.Datasets), 1);
for i = 1:numel(info.Datasets)
  location = ['/ebsd/cs/' num2str(i)];
  cs{i} = loadSymmetry(fname, location);
end
cs = cs';

%% Read unit cell
unitCell = h5read(fname, '/ebsd/unitCell');

%% Read options
info = h5info(fname, '/ebsd/options/');
options = struct();
for i = 1:numel(info.Datasets)
  name = info.Datasets(i).Name;
  location = ['/ebsd/options/', name];
  data = h5read(fname, location);
  options.(name) = data;
end

%% Construct EBSD
ebsd = EBSD(rotations,phases,cs,options,'unitCell', unitCell);

end

function sym = loadSymmetry(fname, location)
  name = h5readatt(fname, location, 'name');
  
  info = h5info(fname, location);
  if numel(info.Attributes) == 1
    sym = name;
  else
    axesLength = h5readatt(fname, location, 'axes');
    axesAngle = h5readatt(fname, location, 'angles');
    mineral = h5readatt(fname, location, 'mineral');

    sym = symmetry(name, axesLength, axesAngle, 'mineral', mineral);
  end
end