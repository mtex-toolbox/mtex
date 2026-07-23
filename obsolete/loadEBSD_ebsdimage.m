function ebsd = loadEBSD_ebsdimage(fname,varargin)

% Check extension
[~, basename, ext] = fileparts(fname);
if ~strcmp(ext, '.zip')
  error('MTEX:wrongInterface','Interface EBSD-Image does not fit file format!');
end

% Create temporary folder to extract ZIP
zipdir = fullfile(tempdir, basename);
status = mkdir(zipdir);
if ~status
  error('MTEX:wrongInterface','Cannot create temporary folder');
end

% Extract ZIP
unzip(fname, zipdir);

% Read alias.properties
text = fileread(fullfile(zipdir, 'alias.properties'));

expr = '[\w\.\-\_]+=(\w+)[^\n]*';
infos = regexp(text, expr, 'match');
splits = regexp(infos, '=', 'split');

lookup = containers.Map();
for i = 1:length(splits)
  key = splits{i}{1};
  value = splits{i}{2};
  lookup(key) = value;
end

if isempty(lookup)
  error('MTEX:wrongInterface', 'No map in zip');
end

% Setup pixel coordinates
% Read calibration
text = fileread(fullfile(zipdir, 'multimap.properties'));

expr = '[\w\.]+=(\w+)[^\n]*';
infos = regexp(text, expr, 'match');
splits = regexp(infos, '=', 'split');

properties = containers.Map();
for i = 1:length(splits)
  key = splits{i}{1};
  value = splits{i}{2};
  properties(key) = value;
end

dx = typecast(sscanf(properties('calibration.dx'), '%lu'), 'double');
dy = typecast(sscanf(properties('calibration.dy'), '%lu'), 'double');

if strcmp(properties('calibration.origin.set'), 'true')
  x0 = typecast(sscanf(properties('calibration.x0'), '%lu'), 'double');
  y0 = typecast(sscanf(properties('calibration.y0'), '%lu'), 'double');
else
  x0 = 0.0;
  y0 = 0.0;
end

if strcmp(properties('calibration.flip.x'), 'true')
  flipx = 1;
else
  flipx = 0;
end
if strcmp(properties('calibration.flip.y'), 'true')
  flipy = 1;
else
  flipy = 0;
end

% Read size
lookup_keys = keys(lookup);
data = readMap(fullfile(zipdir, lookup(lookup_keys{1})));
[width, height] = size(data);
data_length = numel(data);

% Create coordinates
xs = zeros(data_length, 1);
ys = zeros(data_length, 1);

index = 1;
for j = 0:height-1
  for i = 0:width-1
    if flipx
      xs(index) = i*dx; %x0 - dx * i;
    else
      xs(index) = i*dx; %x0 + dx * i;
    end
    
    if flipy
      ys(index) = j*dy; %y0 - dy * j;
    else
      ys(index) = j*dy; %y0 + dy * j;
    end
    
    index = index + 1;
  end
end

options = struct();
options.x = xs;
options.y = ys;

unitCell = calcUnitCell([xs, ys], 'GridType', 'rectangular');

% Read phases

if isKey(lookup, 'Phases')
  phases = reshape(readMap(fullfile(zipdir, lookup('Phases'))), ...
                   data_length, 1);
  
  % TODO: Import Phases.xml
  
  lookup = remove(lookup, 'Phases');
else
  phases = ones(data_length, 1, 'int32');
end

% Read orientations
if isKey(lookup, {'Q0', 'Q1', 'Q2', 'Q3'})
  q0 = reshape(readMap(fullfile(zipdir, lookup('Q0'))), data_length, 1);
  q1 = reshape(readMap(fullfile(zipdir, lookup('Q1'))), data_length, 1);
  q2 = reshape(readMap(fullfile(zipdir, lookup('Q2'))), data_length, 1);
  q3 = reshape(readMap(fullfile(zipdir, lookup('Q3'))), data_length, 1);
  
  lookup = remove(lookup, 'Q0');
  lookup = remove(lookup, 'Q1');
  lookup = remove(lookup, 'Q2');
  lookup = remove(lookup, 'Q3');
else
  q0 = zeros(data_length, 1);
  q1 = zeros(data_length, 1);
  q2 = zeros(data_length, 1);
  q3 = zeros(data_length, 1);
end

rotations = rotation(quaternion(q0, q1, q2, q3));

% Read other maps
lookup_keys = keys(lookup);
for i = 1:numel(lookup_keys)
  key = lookup_keys{i};
  value = lookup(key);
  data = reshape(readMap(fullfile(zipdir, value)), data_length, 1);
  
  fieldname = regexprep(key, '[\.\-]', '_');
  options.(fieldname) = data;
end

% Remove temporary folder
status = rmdir(zipdir, 's');
if ~status
  warning('MTEX:wrongInterface','Cannot remove temporary folder');
end

% Construct EBSD object
CSList = {};
ebsd = EBSD(rotations, phases, CSList, options,'unitCell', unitCell);

end

function data = readMap(fname)
  [~, ~, ext] = fileparts(fname);
  if strcmp(ext, '.bmp')
    data = imread(fname);
  elseif strcmp(ext, '.rmp')
    data = readRMP(fname);
  else
    error('MTEX:wrongInterface', ['No loader for extension ', ext]);
  end
end

function data = readRMP(fname)
  % Create the file
  fid = fopen(fname);

  % 4 numbers: header. check them !!
  header = fread(fid, 4, '*char');
  revision = str2num(header(4)); %#ok<ST2NM>

  % Width and height
  dims = fread(fid, 2, 'int32', 'b');

  % Renderer and LUT
  switch revision
    case 1
      % Do nothing
    case 2
    case 4
      fread(fid, 3*256, 'uint8', 'b'); % Skip LUT
    case 3
      rendererLength = fread(fid, 1, 'uint8', 'b');
      fread(fid, rendererLength, 'uint8', 'b'); % Skip renderer name
      fread(fid, 3*256, 'uint8', 'b'); % Skip LUT
    otherwise
      error('MTEX:wrongInterface', ['Cannot load ', header]);
  end

  % pixArray
  data = fread(fid, [dims(1), dims(2)], 'float32', 0, 'b');

  fclose(fid);
end