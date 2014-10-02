function grains = loadGrainSet_hdf5(fname)

%% Read EBSD
ebsd = loadEBSD_hdf5(fname);

%% Read comment
comment = h5readatt(fname, '/grains', 'comment');

%% Read matrices
A_D = loadSparse(fname, '/grains/a_d');
I_DG = loadSparse(fname, '/grains/i_dg');
A_G = loadSparse(fname, '/grains/a_g');
I_FDext = loadSparse(fname, '/grains/i_fdext');
I_FDsub = loadSparse(fname, '/grains/i_fdsub');
F = loadSparse(fname, '/grains/f');
x_V = loadSparse(fname, '/grains/v');

%% Read phase
phase = h5read(fname, '/grains/phase');

%% Read rotations
as = h5read(fname, '/ebsd/rotations/a');
bs = h5read(fname, '/ebsd/rotations/b');
cs = h5read(fname, '/ebsd/rotations/c');
ds = h5read(fname, '/ebsd/rotations/d');

meanRotation = rotation(quaternion(as, bs, cs, ds));

%% Read options
info = h5info(fname, '/grains/options/');
options = struct();
for i = 1:numel(info.Datasets)
  name = info.Datasets(i).Name;
  location = ['/grains/options/', name];
  data = h5read(fname, location);
  options.(name) = data;
end

%% Create object
grainSet.comment  = comment;

grainSet.A_D      = A_D;   clear A_D;
grainSet.I_DG     = I_DG;  clear I_DG;
grainSet.A_G      = A_G;   clear A_G;
grainSet.meanRotation = meanRotation;  clear meanRotation;
grainSet.phase    = phase;          clear phase;
%
grainSet.I_FDext  = I_FDext;        clear I_FDext;
grainSet.I_FDsub  = I_FDsub;        clear I_FDsub;
grainSet.F        = F;              clear F;
grainSet.V        = x_V;            clear x_V;
grainSet.options  = options;

grains = Grain2d(grainSet, ebsd);

end

function s = loadSparse(fname, location)
  i = h5read(fname, [location '/i']);
  j = h5read(fname, [location '/j']);
  v = h5read(fname, [location '/v']);
  s = logical(spconvert([i j v]));
end

