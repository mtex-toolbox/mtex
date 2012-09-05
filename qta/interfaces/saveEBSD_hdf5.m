function saveEBSD_hdf5(ebsd, fname)
% Save EBSD object to HDF5 format
%
%% Input
% ebsd    - @EBSD
% fname   - output filepath
%

% Delete file if it exists
if exist(fname, 'file') == 2
  delete(fname);
end

%% Save header
h5create(fname, '/mtex', [1 1]);
h5writeatt(fname, '/mtex', 'version', getpref('mtex', 'version'));

%% Save rotations
rotations = get(ebsd, 'rotations');

location = '/ebsd/rotations/a';
as = get(rotations, 'a');
h5create(fname, location, size(ebsd));
h5write(fname, location, as);

location = '/ebsd/rotations/b';
bs = get(rotations, 'b');
h5create(fname, location, size(ebsd));
h5write(fname, location, bs);

location = '/ebsd/rotations/c';
cs = get(rotations, 'c');
h5create(fname, location, size(ebsd));
h5write(fname, location, cs);

location = '/ebsd/rotations/d';
ds = get(rotations, 'd');
h5create(fname, location, size(ebsd));
h5write(fname, location, ds);

%% Save phases
% Array
location = '/ebsd/phases';
phases = get(ebsd, 'phase');
h5create(fname, location, size(ebsd));
h5write(fname, location, phases);

% Symmetries
css = get(ebsd, 'CScell');
for i = 1:numel(css)
  cs = css{i};
  location = ['/ebsd/cs/' num2str(i)];
  saveSymmetry(fname, location, cs);
end

location = '/ebsd/ss';
ss = get(ebsd, 'SS');
saveSymmetry(fname, location, ss);

%% Save unit cell
location = '/ebsd/unitCell';
unitCell = get(ebsd, 'unitCell');
h5create(fname, location, size(unitCell));
h5write(fname, location, unitCell);

%% Save options
fields = fieldnames(get(ebsd, 'options'));
for i = 1:numel(fields)
    name = fields{i};
    if strcmp(name, 'mis2mean')
      continue
    end
    data = get(ebsd, name);
    
    location = ['/ebsd/options/', name];
    h5create(fname, location, size(ebsd));
    h5write(fname, location, data);
end

%% Save comment
location = '/ebsd';
comment = get(ebsd, 'comment');
h5writeatt(fname, location, 'comment', comment);

end

function saveSymmetry(fname, location, symmetry) 
  h5create(fname, location, [1 1]);
  
  if isa(symmetry, 'symmetry')
    name = get(symmetry, 'name');
    h5writeatt(fname, location, 'name', name);

    axes = get(symmetry, 'axesLength');
    h5writeatt(fname, location, 'axes', axes);

    angles = get(symmetry, 'axesAngle');
    h5writeatt(fname, location, 'angles', angles);

    mineral = get(symmetry, 'mineral');
    h5writeatt(fname, location, 'mineral', mineral);
  else
    h5writeatt(fname, location, 'name', symmetry);
  end
  
  %TODO: Check if other variables in symmetry must be saved as well
end
