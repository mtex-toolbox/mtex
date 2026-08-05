function [ebsd] = loadEBSD_h5(fname, varargin)

% How it is working:
%   - You load your file of hdf5 format
%   - The program will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object
%
% Options
%  raw        - import the data as recorded by the detector instead of the
%               version cleaned up by the vendor software. Oxford files
%               hold both, everybody else only the raw one
%  dataSet    - which data set to import from a file that holds several
%               of them, either as the number shown in the list printed
%               on import, or as (part of) its name, e.g.
%               EBSD.load(fname,'dataSet',2) or
%               EBSD.load(fname,'dataSet','OIM Map 2')
%  headerOnly - return only phase/header metadata, skip reading the
%               (potentially large) per-pixel position/rotation/phase
%               data and any other top-level category (e.g. electron
%               images). Also lists the data sets the file contains.

% Selecting right config and load------------------------------------------

if ~exist(fname, 'file'), error('File %s not found.', fname); end
info_struct = h5info(fname);

headerOnly = check_option(varargin, 'headerOnly');

% a previous import may have left a data set selected - every lookup below
% starts out unrestricted again
dataSetScope('/');

if check_option(varargin, 'debug')
  isDebug(get_option(varargin, 'debug'));
else
  isDebug(false);
end

folderPath = fullfile(mtex_path, 'interfaces', 'hdf5_config');
fileList = dir(fullfile(folderPath, '*.json'));
Conf = struct();
manufacturer = "unknown"; % overwritten below if any config's key_path resolves

% Check if a type is set --> if so use this type
isManualType = check_option(varargin, 'type');
if isManualType
    targetType = get_option(varargin, 'type'); % z.B. 'Oxford_EBSD'
end

% Check all available configs for match
for i = 1:length(fileList)
  if fileList(i).isdir, continue; end
  
  cur_Conf = read_config(folderPath, fileList(i).name);

  config_keys = cur_Conf.settings.manufacturer_keys.data;
    
  if isManualType
    if any(strcmpi(targetType, config_keys))
      Conf = cur_Conf;
      break;
    end
  else
    try
      [manufacturer, ~] = readConf(info_struct, cur_Conf.settings.key_path, "name", "Manufacturer");    
    catch
      continue; 
    end
  
    if any(contains(manufacturer, config_keys, 'IgnoreCase', true))
      Conf = cur_Conf;
      break;
    end
  end
end

if isempty(fieldnames(Conf))
  error("No Manufacturer config found for: " + manufacturer);
end

% Oxford files hold the map twice: as recorded by the detector under
% "EBSD" and as cleaned up by the vendor software under "Data Processing".
% The two are described by two configs - 'raw' asks for the first one.
% Vendors that store only one version have no rawConfig, and for them the
% data imported is the unprocessed one anyway, so the option is a no-op.
if check_option(varargin, 'raw') && ~isManualType && isfield(Conf.settings, 'rawConfig')
  Conf = read_config(folderPath, Conf.settings.rawConfig.data + ".json");
end

% Check if user wants to use a different ebsd_key
if check_option(varargin, 'ebsd_key')
  try
    Conf.ebsd.key.value = get_option(varargin, 'ebsd_key');
    warning([ ...
        'You have manually overridden the ebsd_key! ' ...
        'Make sure that your specified key ' ...
        'exists and is unique, otherwise an error occurs!']);  
  catch ME
        error('Error when setting ebsd_key option: %s', ME.message);    
  end
end

% Select the data set to import -------------------------------------------
% Vendor files are project files: an EDAX .edaxh5 nests
% <project>/<sample>/Area N/OIM Map N/EBSD, an Oxford .h5oina nests
% /1, /2, ... - so the config's ebsd key alone may well be ambiguous.
% Enumerate what the file holds and let the user pick one of them.

dataSets = find_dataSets(info_struct, Conf);
requested = get_option(varargin, 'dataSet', []);
iSet = select_dataSet(dataSets, requested);

if ~isempty(iSet)
  if isfield(Conf.ebsd, 'key')
    Conf.ebsd.key = struct('mode', 'absolute', 'value', dataSets(iSet).path);
  end
  % properties, header, images and the values a config reads next to the
  % data set (step size, grid size, ...) have to come from the very same
  % data set
  dataSetScope(parent_path(dataSets(iSet).path));
end

% generate config info text
if ~check_option(varargin,'silent')
  fprintf('\n%s\n', repmat('═', 1, 80));
  fprintf('HDF5 CONFIGURATION LOADED\n');
  fprintf('├── Manufacturer : %s\n', Conf.settings.name);
  if isfield(Conf.settings, 'manufacturer_info')
    % disp adds the line break - a trailing one here would wrap into an
    % empty paragraph and leave a blank line in the middle of the block
    wraptext(sprintf('├── Info         : %s', Conf.settings.manufacturer_info.data));
  end
  % a config that has a raw counterpart holds the vendor's cleaned up
  % version - say so, the option is hard to guess otherwise
  if isfield(Conf.settings, 'rawConfig')
    fprintf('├── Data         : post processed, use ''raw'' for the data as recorded\n');
  end
  % staying quiet about the other data sets would silently import one of
  % several maps - so say which one was taken whenever there is a choice
  if ~isempty(iSet) && (headerOnly || (numel(dataSets) > 1 && isempty(requested)))
    fprintf('%s', dataSets2str(dataSets, iSet));
  end
  fprintf('%s\n', repmat('═', 1, 80));
end

% Get absolute paths and load data-----------------------------------------

exclude = ["settings", "additions"];
data = struct();

if headerOnly
  % only the phase/header metadata under "ebsd" is needed; skip any
  % other top-level category (e.g. electron_image) and strip the
  % expensive per-pixel sub-fields within "ebsd" itself, so they are
  % never read at all
  otherCats = setdiff(string(fieldnames(Conf)), ["ebsd", exclude]);
  exclude = [exclude, reshape(otherCats, 1, [])];
  % map_correction is a small lookup table, not per-pixel data, and
  % EDAX's config caches a value under it that how2plot reuses - so it
  % must stay, only the genuinely bulk per-pixel fields are stripped
  bulkFields = intersect(fieldnames(Conf.ebsd), {'position','phase','rotation'});
  Conf.ebsd = rmfield(Conf.ebsd, bulkFields);

  % explicit marker for ebsd_default (uses the same inline-"data"
  % convention as map_correction/how2plot's fixed lookup tables above) -
  % deliberately NOT inferred from position/phase/rotation being absent,
  % since a malformed file can legitimately fail to resolve those too,
  % and that must still raise the normal "missing fields" error rather
  % than silently produce an empty EBSD
  Conf.ebsd.headerOnlyFlag = struct('data', true);
end

categories = fieldnames(Conf);
try
  for i = 1:length(categories)
  
    cat = categories{i};
    if ismember(cat, exclude), continue; end
  
    vprintf(isDebug(), '\n 🔷 [%s]\n', upper(string(cat)));
    vprintf(isDebug(), ' %s\n', repmat('─', 1, 80));
  
    [data.(cat), Conf.(cat)] = readConf( ...
      info_struct, ...
      Conf.(cat), ...
      "name", cat);
  
    vprintf(isDebug(), ' %s\n', repmat('─', 1, 80));
    vprintf(isDebug(), '  [OK] %s successfully initialized\n', string(cat));
  
  end
catch ME
  disp(ME.getReport)
  % Check which type is currently loaded
  current_type = '';
  if check_option(varargin, 'type')
    current_type = get_option(varargin, 'type');
  end

  % Only try fallback if one exists and is different from the current 
  if isfield(Conf.settings, 'fallback') && ~strcmpi(current_type, Conf.settings.fallback)
    warning("Someting went wrong! Trying fallback: '%s'. The Error was: '%s'", Conf.settings.fallback, ME.message);
    
    % Restart with fallback version
    ebsd = loadEBSD_h5(fname, 'type', Conf.settings.fallback, 'debug', isDebug(), ...
      'headerOnly', headerOnly, 'dataSet', requested);
    return;
  else 
    error('loadEBSD_h5 failed. No more Fallbacks available.\nError code: %s', ME.message);
  end
end

% Construct prop-----------------------------------------------------------

prop_data = struct();

try

  if ~headerOnly && isfield(Conf, 'additions')
    if Conf.additions.type == "auto"
  
      opt_prop = struct("root", "/", "optional", true, "name", "prop", ...
        "level", 1, "multiple", false);
  
      prop_data = fetch_from_group(info_struct, Conf.additions, opt_prop);
  
      h = get_hdf5_path(info_struct, Conf.additions.group);
    
      paths_allready_used = search_Conf(Conf, 'path', h);
  
      [~, exclude_fields] = cellfun(@fileparts, paths_allready_used, 'UniformOutput', false);

      for i = 1:length(exclude_fields)
        exclude_fields{i} = clean_string(exclude_fields{i});
      end

      prop_fields = fieldnames(prop_data);

      for i = 1:length(prop_fields)
        cur_field = prop_fields{i};
        if ismember(cur_field, exclude_fields)
          prop_data = rmfield(prop_data, cur_field);
        end
      end
    else
      warning("Still to do when additions is not auto...")
    end
  end
catch ME 
  disp("Error building prop struct")
  disp(ME.getReport)
end

% Building output data-----------------------------------------------------

data.ebsd.prop = prop_data;

fields = fieldnames(data);
for i = 1:length(fields)

  field = fields{i};
  if field == "ebsd", continue; end
  if isempty(data.(field)), continue; end
  data.ebsd.opt.(field) = data.(field);

end

ebsd = data.ebsd;

% remember where the data came from and what else the file has to offer
if ~isempty(iSet)
  ebsd.opt.dataSet = dataSets(iSet).path;
  if numel(dataSets) > 1, ebsd.opt.dataSets = [dataSets.path]; end
end

% Euler <-> map reference frame -------------------------------------------
% Normally the correction is stated in the file and has been picked up by
% the config above. An explicitly given 'setting' / 'EulerCorrection' still
% wins, and if an EDAX flavoured file did not state it at all (.edaxh5
% writes -1 as coordinate system id) the user is asked for it, just as the
% .ang and .osc interfaces do.
[~,~,ext] = fileparts(fname);
if check_option(varargin,{'setting','EulerCorrection'})
  ebsd = applyEulerCorrectionTable(ebsd,ext,varargin{:});
elseif startsWith(string(Conf.settings.name),"EDAX","IgnoreCase",true) && ...
    ebsd.EulerCorrection.angle < 1e-6
  ebsd = applyEulerCorrectionTable(ebsd,ext);
end

end

%% Formating functions

function out = position_direct(raw_data)

  if ~isfield(raw_data, 'x') || ~isfield(raw_data, 'y')
    error('Position data has type direct but not the needed fields x and y')
  end

  out = vector3d(double(raw_data.x), double(raw_data.y), 0);

end

function out = position_indirect(raw_data)

  if ~all(isfield(raw_data, {'step_size_x', 'step_size_y', 'grid_size_x', 'grid_size_y'}))
    error('Position data has type ''indirect'', but ''step_size_x'', ''step_size_y'', ''grid_size_x'' or ''grid_size_y'' is missing!');
  end

  % set which variable comes first --> default x first
  first = 'x';
  if isfield(raw_data, 'first')
    first = raw_data.first;
  end

  step_x = double(raw_data.step_size_x);
  step_y = double(raw_data.step_size_y);
  cells_x = double(raw_data.grid_size_x);
  cells_y = double(raw_data.grid_size_y);

  v_x = 0:step_x:(cells_x-1)*step_x;
  v_y = 0:step_y:(cells_y-1)*step_y;
  
  if first == 'x'
    [x, y] = ndgrid(v_x, v_y);
  elseif first == 'y'
    [x, y] = meshgrid(v_x, v_y);
  end

  out = vector3d(x(:), y(:), 0);
end

function out = rotation_byMatrix(M)
%ROTATION_BYMATRIX  Build a MTEX rotation from 3x3 orientation matrices.

  if nargin < 1
    error('rotation_byMatrix: no input given.');
  end

  out = reshape(rotation.byMatrix(ensure_3x3xN(double(M))),[],1);

  function M3 = ensure_3x3xN(M)
  %ENSURE_3X3XN  Coerce a 9xN, Nx9, 3x3 or 3x3xN array to 3x3xN.
  %
  % The 9 values of one pixel are stored column by column - this is the
  % order EDAX writes its "Orientations" records in, verified against the
  % Euler angles of the very same map exported as .ang.
  if ndims(M) == 3 && size(M,1) == 3 && size(M,2) == 3
    M3 = M;                                 % already 3x3xN
    return
  end
  if ismatrix(M)
    [h, w] = size(M);
    if h == 3 && w == 3
        M3 = reshape(M, 3, 3, 1);           % single matrix
        return
    end
    if h == 9 && w > 1
        % 9 x N: each COLUMN is one pixel's 9 values
        M3 = reshape(M, 3, 3, []);
        return
    end
    if w == 9 && h > 1
        % N x 9: each ROW is one pixel's 9 values
        M3 = reshape(M', 3, 3, []);
        return
    end
  end
  error(['rotation_byMatrix: matrix must be 3x3, 3x3xN, 9xN or Nx9. ' ...
         'Got size [%s].'], num2str(size(M)));
  end
end

function out = rotation_euler(raw_data)

  fields = fieldnames(raw_data);

  if isempty(fields) || length(fields) > 4 || ~ismember('format', fields)
    error(['Rotation data has type euler but not enough fields or too many' ...
      'field. You need to give 1-3 Fields and one named format for degree or radiant format.'])
  end

  % Determine format if set
  try
    format = determineformate(raw_data);
  catch ME
    error("map_correction_default: " + ME.message);      
  end

  % Collect all fields and stick them together in one matrix
  matrix = cell(1, length(fields));
  for i = 1:length(fields)

    field_name = fields{i};

    if field_name == "format"
      continue;
    end

    [h, w] = size(raw_data.(fields{i}));

    if h > w
      matrix{i} = double(raw_data.(fields{i}));
    else
      matrix{i} = double((raw_data.(fields{i}))');
    end
  end

  phi = horzcat(matrix{:});
  out = rotation.byEuler(phi * format);
end

function out = rotation_euler_stack(raw_data)

  if ~isfield(raw_data, 'phi')
    error(['Rotation data has type euler_stack but not the correct fields where given!' ...
      ' Make sure you have phi field.'])
  end

  % Determine format if set
  try
    format = determineformate(raw_data);
  catch ME
    error("map_correction_default: " + ME.message);      
  end

  phi1_2D = raw_data.phi(1,:,:);
  Phi_2D  = raw_data.phi(2,:,:);
  phi2_2D = raw_data.phi(3,:,:);

  out = rotation.byEuler(phi1_2D(:)*format, Phi_2D(:)*format, phi2_2D(:)*format);
end

function out = unitCell_fromStep(raw_data)
% build a rectangular unit cell hint from a vendor's own step-size
% header fields (see EBSD/updateUnitCell) - calcUnitCell's position
% estimate can be badly wrong for "direct" position vendors (X/Y read
% straight from a per-pixel dataset, not built from step size), where
% it has been observed to collapse to a meaningless placeholder value
  xs = double(raw_data.step_size_x);
  ys = double(raw_data.step_size_y);
  out = vector3d([xs,xs,-xs,-xs]/2,[-ys,ys,ys,-ys]/2,0);
end

function out = cs_default(raw_data)

  if ~all(isfield(raw_data, {'space_group', 'lattice', 'name'}))
    error('Cs data has type ''default'', but ''space_group'', ''lattice'' or ''name'' is missing!');
  end

  % create depending if reference frame is there
  if isfield(raw_data, 'reference_frame')
    out = crystalSymmetry( ...
      raw_data.space_group, ...
      raw_data.lattice.dim, ...
      raw_data.lattice.angle, ...
      raw_data.reference_frame,...
      'Mineral', ...
      raw_data.name);
  else
    out = crystalSymmetry( ...
      raw_data.space_group, ...
      raw_data.lattice.dim, ...
      raw_data.lattice.angle, ...
      'Mineral', ...
      raw_data.name);
  end

  % structural information beyond the point group. MTEX does not model
  % translational symmetry, so keep it as stated by the vendor instead of
  % dropping it
  if isfield(raw_data,'space_group_id') && ~isempty(raw_data.space_group_id)
    out.opt.spaceId = double(raw_data.space_group_id);
  end
  if isfield(raw_data,'atoms') && ~isempty(raw_data.atoms)
    out.opt.atoms = raw_data.atoms;
  end

end

function out = space_group_default(raw_data)


  if isnumeric(raw_data)
    clean = double(raw_data);
    id = symmetry.extractPointId('spaceId', clean);
  else
    % vendors state the group as a name, sometimes decorated like
    % "Hexagonal (D6h) [6/mmm]" - then only the bracket is the group
    raw_data = char(string(raw_data));
    inBrackets = regexp(raw_data,'\[([^\]]+)\]','tokens','once');
    if ~isempty(inBrackets), raw_data = inBrackets{1}; end

    clean = clean_string(raw_data);
    id = symmetry.extractPointId(clean);
  end
  out = symmetry.pointGroups(id).Inter;

end

function out = space_group_TSLNumber(raw_data)
% EDAX / TSL store the symmetry as a numeric code, e.g. 43 for cubic -
% the very same codes as in the .ang / .osc header. It only distinguishes
% the 11 Laue groups.

  out = TSL2pointGroup(raw_data);

end

function out = space_group_EDAX(raw_data)
% EDAX states the symmetry as the numeric TSL code, which gives the Laue
% group only, and - in newer files - as the actual point group, either as
% the id "PGsymID" / "PointGroupID" or as a name like
% "Hexagonal (D6h) [6/mmm]". Both are read separately since one config
% entry must never match more than one data set per phase.

  pointGroup = [];
  if isfield(raw_data,'point_group_id') && ~isempty(raw_data.point_group_id)
    pointGroup = raw_data.point_group_id;
  elseif isfield(raw_data,'point_group_name')
    pointGroup = raw_data.point_group_name;
  end

  out = TSL2pointGroup(raw_data.laue_code,pointGroup);

end

function out = atoms_default(raw_data)
% the atomic basis as stated by the vendor, one dataset per atom holding a
% string like "Zr,3.333E-1,6.667E-1,2.5E-1,1,0" - kept as read since MTEX
% has no model of the crystal structure to feed it into

  out = {};
  if ~isstruct(raw_data), return; end

  % x1, x2, ... - the atoms in the order the vendor stored them
  fn = sort(fieldnames(raw_data));
  for i = 1:numel(fn)
    out = [out, cellstr(string(raw_data.(fn{i})))']; %#ok<AGROW>
  end

end

function out = lattice_all_together(raw_data)

  try
    dimension = double(raw_data(1:3));
    angles = double(raw_data(4:6))*degree;
  catch
    error("lattice_all_together has trouble reading the data. Make sure" + ...
      " the there are 6 entrys and the first 3 are the dimension and the last 3 the angles")
  end

  out = struct();
  out.dim = dimension;
  out.angle = angles;

end

function out = angle_separate(raw_data)

  if ~all(isfield(raw_data, {'lattice_alpha', 'lattice_beta', 'lattice_gamma'}))
    error('Angle data has type ''separate'', but ''lattice_alpha'', ''lattice_beta'' or ''lattice_gamma'' is missing!');
  end

  alpha = double(raw_data.lattice_alpha)*degree;
  beta = double(raw_data.lattice_beta)*degree;
  gamma = double(raw_data.lattice_gamma)*degree;

  out = [alpha, beta, gamma];
end

function out = dim_separate(raw_data)

  if ~isfield(raw_data, 'lattice_a') || ~isfield(raw_data, 'lattice_b') || ~isfield(raw_data, 'lattice_c')
    error(['Cs angle data has type separate but not the correct fields were given. ' ...
      'Make sure you have a lattice_a, lattice_b and lattice_c!'])
  end

  a = double(raw_data.lattice_a);
  b = double(raw_data.lattice_b);
  c = double(raw_data.lattice_c);

  out = [a, b, c];
end

function out = phase_stack(raw_data)

  out = double(raw_data(:));

end

function out = phase_default(raw_data)

  out = double(raw_data);

end

function out = ebsd_default(raw_data)

  % Check if cs is set --> if not create simple (an optional "cs" whose
  % key search comes up empty is present but [], not absent, hence the
  % isempty check too)
  if ~isfield(raw_data, 'cs') || isempty(raw_data.cs)
    raw_data.cs = notIndexed;
  end

  header = struct();
  if isfield(raw_data, 'header')
    header = raw_data.header;
  end

  if isfield(raw_data, 'headerOnlyFlag') && raw_data.headerOnlyFlag
    % loadEBSD_h5's 'headerOnly' option deliberately stripped
    % position/phase/rotation from the config before this ran and set
    % this flag explicitly - unlike inferring headerOnly from their
    % absence, this can't be confused with a malformed file that
    % legitimately fails to resolve those fields (which must still hit
    % the "missing fields" error below, not silently produce an empty
    % EBSD)
    if isfield(raw_data, 'unitCell')
      out = emptyHeaderOnlyEBSD(raw_data.cs, header, 'unitCellHint', raw_data.unitCell);
    else
      out = emptyHeaderOnlyEBSD(raw_data.cs, header);
    end
    if isfield(raw_data, 'map_correction')
      out.EulerCorrection = raw_data.map_correction;
    end
    return
  end

  if ~isfield(raw_data, 'position') || ~isfield(raw_data, 'phase') || ~isfield(raw_data, 'rotation')
    error(['EBSD data has not the correct fields! ' ...
      'Make sure you have a position, rotation, phase and field!'])
  end

  if ~isequal(numel(raw_data.position), numel(raw_data.rotation), numel(raw_data.phase))
    error('Array dimension mismatch! position (%d), rotation (%d), and phase (%d) must have the exact same number of elements.', ...
          numel(raw_data.position), numel(raw_data.rotation), numel(raw_data.phase));
  end

  prop = struct();

  unitCellHint = {};
  if isfield(raw_data, 'unitCell')
    unitCellHint = {'unitCellHint', raw_data.unitCell};
  end

  ebsd = EBSD(raw_data.position, raw_data.rotation, raw_data.phase, raw_data.cs, prop, unitCellHint{:});

  % if a correction is set add
  if isfield(raw_data, 'map_correction')
    ebsd.EulerCorrection = raw_data.map_correction;
  end

  ebsd.opt.header = header;

  % if a how2plot is set add
  if isfield(raw_data, 'how2plot')
    ebsd.how2plot = raw_data.how2plot;
  end

  out = ebsd;

end

function out = image_data_default(raw_data)

  if ~isfield(raw_data, 'FSE') || ~isfield(raw_data, 'SE') || ~isfield(raw_data, 'x_size') || ~isfield(raw_data, 'y_size')
    error(['image_data default has not the correct fields! ' ...
      'Make sure you have a FSE, SE, x_size and y_size field!'])
  end

  out = struct;

  x_size = double(raw_data.x_size);
  y_size = double(raw_data.y_size);

  FSE = raw_data.FSE;
  SE = raw_data.SE;

  function dst = copy_reshaped(src, dst, x, y)
    for n = fieldnames(src)'
      dst.(n{1}) = double(permute(reshape(src.(n{1})(:),[x,y]),[2 1]));
    end
  end

  out = copy_reshaped(FSE, out, x_size, y_size);
  out = copy_reshaped(SE,  out, x_size, y_size);
end

function out = image_data_images(raw_data)
% Every dataset of an image group as it is stored, e.g. the SEM / PRIAS
% images EDAX keeps next to the EBSD data. Unlike image_data_default
% these are already two dimensional and need no reshaping - only the
% transpose from HDF5's column major layout to MTEX's row major images.

  out = struct;

  for n = fieldnames(raw_data)'
    img = double(raw_data.(n{1}));
    if ~isvector(img), img = img.'; end
    out.(n{1}) = img;
  end

end

function out = electron_image_default(raw_data)

  if ~isfield(raw_data, 'image_data') || ~isfield(raw_data, 'header')
    error(['electron_image default has not the correct fields! ' ...
      'Make sure you have a image_data and header field!'])
  end

  out = raw_data.image_data;

  out.Header = raw_data.header;

end

function out = map_correction_rotation(raw_data)

  out = rotation.byEuler(double(raw_data(:).')*degree);

end


function out = map_correction_default(raw_data)

  try
    format = determineformate(raw_data);
  catch ME
    error("map_correction_default: " + ME.message);      
  end

  data = double(raw_data);
  if any(data > 10), format = degree; end

  out = rotation.byEuler(data(:).'*format);

end

function out = map_correction_by_id(raw_data)

  if ~isfield(raw_data, 'id') || ~isfield(raw_data, 'correct_data')
    error(['map_correction__by_id default has not the correct fields! ' ...
      'Make sure you have a id and correct_data field!'])
  end

  try
    format = determineformate(raw_data);
  catch ME
    error("map_correction_default: " + ME.message);      
  end

  id = double(raw_data.id);
  data = raw_data.correct_data;

  % some vendors do not always state the setting, e.g. EDAX writes -1 into
  % .edaxh5 files - then there is nothing to correct here and loadEBSD_h5
  % asks the user for the setting instead
  if id < 1 || id > size(data,1)
    out = rotation.id;
    return
  end

  % either one row of Bunge angles per id or a single rotation angle
  % about the y axis
  if size(data,2) > 1
    out = rotation.byEuler(data(id,:)*format);
  else
    out = rotation.byAxisAngle(yvector, data(id)*format);
  end
end

function out = reference_frame_default(raw_data)

  id = string(raw_data);

  % 'kristall || probe' -> 'PROBE||kristall'
  out = regexprep(id, '(\S+)\s*\|\|\s*([xyzXYZ])', '${upper($2)}||$1');
  
  % 'probe || kristall' -> 'PROBE||kristall'
  out = regexprep(out, '([xyzXYZ])\s*\|\|\s*(\S+)', '${upper($1)}||$2');
  
  out = regexprep(out, '\s*,\s*', ', ');
end

function out = how2plot_by_id(raw_data)

  if ~all(isfield(raw_data, {'how2plot_data', 'id'}))
    error('how2plot data has type ''by_id'', but ''id'' or ''how2plot_data'' field is missing!');
  end
  
  data = raw_data.how2plot_data;
  id = int8(raw_data.id);

  out = sethow2plot(data{id});
end

function out = how2plot_default(raw_data)

  out = sethow2plot(raw_data);

end

%% Helper Functions

function how2plot = sethow2plot(input)

  how2plot = plottingConvention();

  axis = split(input, ',');
  for i = 1:length(axis)
    elements = split(axis{i}, '-');
    coordinate = elements{1};
    direction = elements{2};

    switch lower(coordinate)
      case 'x'
        vecObj = xvector;
      case 'y'
        vecObj = yvector;
      case 'z'
        vecObj = zvector;
      otherwise
        error('Unkown Coordinate: "%s". Use x, y or z', coordinate);
    end

    how2plot.(direction) = vecObj;
  end

  % stay with the default instance if this is the default alignment anyway
  how2plot = matchDefault(how2plot);
end

function format = determineformate(raw_data)
  format = 1;

  if ~isstruct(raw_data) || ~isfield(raw_data, 'format')
    return
  end

  if raw_data.format == "degree"
    format = degree;
    return;
  elseif raw_data.format == "radian"
    return;
  else
    error("Unknown format set!")
  end
end

function cleanName = clean_string(rawName, option)
arguments
  rawName
  option = "full"
end
  rules = {
    '[ ,\-:|%~#\[\]()]',     '';
    'sub(?=\d)',             '';
    'sub(?=[a-zA-Z])',       '/';
    'ovl',                   '-';
  };

  cleanName = rawName;

  if option == "full"
    len = size(rules, 1);
  elseif option == "simple"
    len = 1;
  end

  for r = 1:len
    cleanName = regexprep(cleanName, rules{r, 1}, rules{r, 2}, 'ignorecase');
  end
end

function data = readData(fname, paths)
% small helper function to read data no matter if it is in a cell
  if iscell(paths)
    data = cell(1, length(paths));
    for i = 1:length(paths)
      data{i} = h5read(fname, paths{i});
    end
  else
    data = h5read(fname, paths);
  end
end

function print_debug(label, path, level)
% helper function to handle the debug printing

  indent = repmat('   ', 1, level - 1);
  targetWidth = 45;
  max_length = 55;

  if strlength(path) > max_length
    path = "..." + extractAfter(path, strlength(path)-52);
  end

  fullLabel = string(indent) + string(label);
  fullLabel = pad(fullLabel, targetWidth, 'right');

  vprintf(isDebug(), '%s │ %s\n', fullLabel, path);

end

function vprintf(opt, varargin)
% helper function to only print when debug state is set true

    if opt
        fprintf(varargin{:});
    end
end

function val = isDebug(setVal)
% helper funktion to set debug state

    persistent debugState;
    if nargin > 0
        debugState = setVal;
    end
    val = debugState;
end

function val = dataSetScope(setVal)
% helper function to set the HDF5 group all searches are confined to
%
% Once a data set has been selected (see find_dataSets) every lookup has
% to stay inside it. Otherwise a file with several maps would happily
% combine map 2's orientations with map 1's step size, since each search
% restarts at the file root. "/" means "whole file" and is the state
% before a data set has been picked.

    persistent scope;
    if nargin > 0
        scope = normalize_root(char(setVal));
    end
    if isempty(scope), scope = '/'; end
    val = scope;
end

%% Path resolution --------------------------------------------------------
%
% The functions in this section are the "config -> HDF5 path" bridge.
% - get_hdf5_path : resolve a config item to one (or many) absolute HDF5
%                   paths, dispatching on config_item.mode.
% - flattenH5     : walk an h5info tree once and emit a flat item list.
% - locate_subtree: fetch the h5info sub-tree at a given path (used by
%                   the group-based readers and the additions branch).
% - search_Conf   : walk the JSON config tree and collect path values
%                   already used by explicit config entries.

function final_path = get_hdf5_path(info_struct, config_item, options)
%GET_HDF5_PATH  Resolve a config item to an HDF5 path (or cell of paths).
%
%   The dispatch is driven by config_item.mode:
%       "absolute"    : literal match of the full path
%       "search_root" : regex over paths under options.root
%       "search_free" : regex over all paths of the selected data set
%
%   The h5info tree is flattened once per file and cached in a persistent
%   variable. Subsequent calls in the same session hit the cache

  arguments
    info_struct struct
    config_item struct
    options.root     string  = "/"
    options.multiple logical = false
    options.optional logical = false
  end

  if ~isfield(config_item, 'value') || ~isfield(config_item, 'mode')
    error('get_hdf5_path:badConfig', ...
          'config_item must have "value" and "mode" fields.');
  end

  % Single-slot cache keyed on the filename. New file -> rebuild.
  persistent cache_file cache_items
  fname = info_struct.Filename;
  if isempty(cache_file) || ~strcmp(cache_file, fname)
    cache_file = fname;
    cache_items = flattenH5(info_struct);
  end
  items = cache_items;

  search_val = string(config_item.value);
  mode = string(config_item.mode);

  % Searches are confined to the selected data set - "search_free" means
  % "anywhere in the data set", and an entry that has not been anchored to
  % a key group yet starts at the data set rather than at the file root.
  scope = dataSetScope();
  root = normalize_root(options.root);
  if strcmp(root, '/'), root = scope; end

  % select mode and get matches
  switch mode
    case 'absolute'
      matches = find_absolute(items, search_val);
    case 'search_root'
      matches = find_in_root(items, search_val, root);
    case 'search_free'
      matches = find_in_root(items, search_val, scope);
    otherwise
      error('get_hdf5_path:badMode', ...
            'Unknown mode "%s". Use "absolute", "search_root", or "search_free".', mode);
  end

  % evaluate matches --> build output final_path
  if isempty(matches)
    if options.optional
      final_path = "";
    else
      error('get_hdf5_path:notFound', ...
            'No match for value "%s" (mode "%s").', search_val, mode);
    end
  else
    if options.multiple
      final_path = cellfun(@(x) string(x.FullPath), matches, 'UniformOutput', false);
    else
      if length(matches) > 1
        vprintf(isDebug(), ...
                '   ⚠ %d matches for "%s" (mode "%s"); returning first.\n', ...
                length(matches), search_val, mode);
        vprintf(isDebug(), string(matches{1}.FullPath))
      end
      final_path = string(matches{1}.FullPath);
    end
  end
end

function Conf = read_config(folderPath, name)
% Read one of the vendor configs in interfaces/hdf5_config.

  fullFileName = fullfile(folderPath, char(name));

  try
    Conf = jsondecode(fileread(fullFileName));
  catch ME
    error('Error when loading "%s": %s', fullFileName, ME.message);
  end
end

function sets = find_dataSets(info_struct, Conf)
%FIND_DATASETS  Enumerate the data sets an HDF5 file holds.
%
%   sets = find_dataSets(info_struct, Conf) returns a struct array with
%   the fields
%       path  - full HDF5 path of the data set
%       label - the part of the path that distinguishes it from the others
%
%   Every map of a project file matches the config's ebsd key, so the
%   matches of that key are the natural candidate list. Two things have to
%   be sorted out first: a regex like "/EBSD" matches the data set group
%   *and* everything below it, and a regex broad enough to catch every map
%   also catches unrelated groups - Oxford's "EBSD Layered Image" for the
%   key "EBSD". Hence the two filter steps below.
%
%   See also: select_dataSet, dataSetScope

  % without a key the whole file is one data set
  if ~isfield(Conf, 'ebsd') || ~isfield(Conf.ebsd, 'key')
    sets = struct('path', "/", 'label', "/");
    return
  end

  % a key that does not resolve at all is not this function's business to
  % report - an empty list leaves the config untouched, so the category
  % loop raises the proper error and the config fallback still kicks in
  try
    paths = get_hdf5_path(info_struct, Conf.ebsd.key, "multiple", true);
  catch
    sets = struct('path', {}, 'label', {});
    return
  end
  if ~iscell(paths), paths = {paths}; end
  paths = string(paths(:));

  % keep only the topmost node of each chain of matches
  keep = true(size(paths));
  for i = 1:numel(paths)
    for j = 1:numel(paths)
      if i ~= j && keep(j) && ~strcmp(paths(i), paths(j)) && ...
          path_starts_with(char(paths(i)), char(paths(j)))
        keep(i) = false;
        break
      end
    end
  end
  paths = paths(keep);

  % keep only candidates under which the mandatory entries of the ebsd
  % category actually resolve
  req = required_keys(rmfield(Conf.ebsd, 'key'));
  isSet = true(size(paths));
  for i = 1:numel(paths)
    for k = 1:numel(req)
      try
        get_hdf5_path(info_struct, req{k}, "root", paths(i));
      catch
        isSet(i) = false;
        break
      end
    end
  end
  % if the config is too exotic for this check nothing is gained by
  % discarding everything - fall back to the unvalidated list
  if any(isSet), paths = paths(isSet); end

  labels = short_labels(paths);
  sets = struct('path', num2cell(paths), 'label', num2cell(labels));
  sets = reshape(sets, 1, []);
end

function req = required_keys(node, optional, req)
%REQUIRED_KEYS  Collect the config entries a data set must provide.
%
%   These are the non-optional entries searched relative to the data set
%   root. "search_free" and "absolute" entries are deliberately skipped:
%   they are anchored at the enclosing scope, not at the data set itself
%   (e.g. EDAX reads the step size from a Sample group *next to* EBSD).

  if nargin < 2, optional = false; end
  if nargin < 3, req = {}; end
  if ~isstruct(node) || isempty(fieldnames(node)), return; end

  % optionality is inherited by the whole branch, as in readConf
  if isfield(node, 'optional'), optional = optional || logical(node.optional); end
  if optional, return; end

  if isfield(node, 'mode') && isfield(node, 'value') && ...
      ~isfield(node, 'fallback') && strcmpi(string(node.mode), "search_root")
    req{end+1} = struct('mode', 'search_root', 'value', node.value);
  end

  for f = fieldnames(node)'
    req = required_keys(node.(f{1}), optional, req);
  end
end

function labels = short_labels(paths)
% Strip the leading path segments all data sets share - what remains is
% what tells them apart ("Area 1/OIM Map 1/EBSD" instead of the full
% "/Kamila Ti/Ti c axis/Area 1/OIM Map 1/EBSD").

  parts = arrayfun(@(p) split(p, "/"), paths, 'UniformOutput', false);

  nCommon = 0;
  if numel(paths) > 1
    minLen = min(cellfun(@numel, parts));
    while nCommon < minLen - 1 && ...
        all(cellfun(@(p) strcmp(p(nCommon+1), parts{1}(nCommon+1)), parts))
      nCommon = nCommon + 1;
    end
  end

  labels = arrayfun(@(i) join(parts{i}(nCommon+1:end), "/"), (1:numel(paths))');
end

function iSet = select_dataSet(sets, requested)
%SELECT_DATASET  Turn a 'dataSet' option value into an index into sets.
%
%   requested is either empty (take the first one), a number (the position
%   in the list) or a string matching part of a data set's label or path,
%   case insensitive. An empty sets means the config did not resolve at
%   all - the resulting empty index leaves the import untouched.

  if isempty(sets)
    if ~isempty(requested)
      error('loadEBSD_h5:badDataSet', ...
        'This file does not contain any data set to select from.');
    end
    iSet = [];
    return
  end

  if isempty(requested), iSet = 1; return; end

  if isnumeric(requested)
    if ~isscalar(requested) || requested ~= round(requested) || ...
        requested < 1 || requested > numel(sets)
      error('loadEBSD_h5:badDataSet', ...
        'There is no data set number %s in this file.\n%s', ...
        num2str(requested), dataSets2str(sets));
    end
    iSet = requested;
    return
  end

  requested = string(requested);
  hit = find(contains([sets.label], requested, 'IgnoreCase', true) | ...
             contains([sets.path],  requested, 'IgnoreCase', true));

  if isempty(hit)
    error('loadEBSD_h5:badDataSet', ...
      'There is no data set matching "%s" in this file.\n%s', ...
      requested, dataSets2str(sets));
  elseif ~isscalar(hit)
    error('loadEBSD_h5:ambiguousDataSet', ...
      '"%s" matches %d data sets - please be more specific.\n%s', ...
      requested, numel(hit), dataSets2str(sets, hit));
  end

  iSet = hit;
end

function str = dataSets2str(sets, selected)
% The data set list as it is printed on import and in error messages.

  if nargin < 2, selected = []; end

  if isscalar(sets)
    str = sprintf('├── Data set     : %s\n', sets(1).path);
    return
  end

  str = sprintf('├── Data sets    : %d\n', numel(sets));
  for k = 1:numel(sets)
    if ismember(k, selected)
      marker = '▸';
    else
      marker = ' ';
    end
    str = [str sprintf('│   %s [%d] %s\n', marker, k, sets(k).label)]; %#ok<AGROW>
  end
  str = [str sprintf('└── Pick one by EBSD.load(fname,''dataSet'',%d) or ''dataSet'',''%s''\n', ...
    numel(sets), sets(end).label)];
end

function p = parent_path(path)
% The group containing the given path, '/' for a top level one.
  p = regexprep(char(normalize_path(path)), '/[^/]*$', '');
  if isempty(p), p = '/'; end
end

function matches = find_absolute(items, search_val)
% Literal, case-sensitive path match.
  target = normalize_path(search_val);
  matches = {};
  for i = 1:length(items)
    if strcmp(items{i}.FullPath, target)
      matches = items(i);
      return
    end
  end
end

function matches = find_in_root(items, pattern, root_val)
% Regex match over paths that start with root_val (segment-aware).
  matches = {};
  for i = 1:length(items)
    p = items{i}.FullPath;
    if ~path_starts_with(p, root_val), continue; end
    if ~isempty(regexpi(p, pattern, 'once'))
      matches{end+1} = items{i};
    end
  end
end

function p = normalize_path(s)
% Strip leading/trailing slashes, then force exactly one leading slash.
  p = char(s);
  p = regexprep(p, '^/+', '');
  p = regexprep(p, '/+$', '');
  p = ['/' p];
  if length(p) > 1
    p = regexprep(p, '/{2,}', '/');
  end
  if strcmp(p, '//'), p = '/'; end
end

function r = normalize_root(s)
% Normalize a search_root: always absolute, no trailing slash.
  r = char(s);
  if isempty(r), r = '/'; return; end
  if r(1) ~= '/', r = ['/' r]; end
  r = regexprep(r, '/+$', '');
  if isempty(r), r = '/'; end
end

function tf = path_starts_with(p, root)
% Segment-aware prefix check: "/EBSD" matches "/EBSD/Phase1" but not "/EBSDx".
  if strcmp(root, '/'), tf = true; return; end
  n = length(root);
  tf = length(p) >= n && strncmp(p, root, n) && ...
       (length(p) == n || p(n+1) == '/');
end

function items = flattenH5(rootNode)
%FLATTENH5  Flatten an h5info tree into a cell array of items.
%
%   Each emitted item is augmented with a FullPath string starting with
%   '/'. Datasets and attributes are leaves; groups are emitted as nodes
%   and also recursed into. The walker is the only thing that builds
%   FullPath, so it is the single source of truth for path consistency.
%
%   See also: get_hdf5_path

  items = walk_s(rootNode, '/');
end

function items = walk_s(node, curPath)
  items = {};

  % Datasets
  if isfield(node, 'Datasets') && ~isempty(node.Datasets)
    for i = 1:length(node.Datasets)
      ds = node.Datasets(i);
      ds.FullPath = join_path(curPath, ds.Name);
      items{end+1} = ds;
    end
  end

  % Attributes
  if isfield(node, 'Attributes') && ~isempty(node.Attributes)
    for i = 1:length(node.Attributes)
      attr = node.Attributes(i);
      attr.FullPath = join_path(curPath, ['@' attr.Name]);
      items{end+1} = attr;
    end
  end

  % Groups (emit node, then recurse with the accumulated full path)
  if isfield(node, 'Groups') && ~isempty(node.Groups)
    for i = 1:length(node.Groups)
      g = node.Groups(i);
      gPath = g.Name;
      g.FullPath = gPath;
      items{end+1} = g;
      items = [items, walk_s(g, gPath)];
    end
  end
end

function p = join_path(base, name)
  if strcmp(base, '/')
    p = ['/' name];
  else
    p = [base '/' name];
  end
end

function node = locate_subtree(info_struct, target_path)
%LOCATE_SUBTREE  Return the h5info sub-tree at the given absolute path.
%
%   Uses h5info's own path resolution so we do not have to walk the
%   in-memory tree. target_path must be absolute (leading '/') or empty.

  target = normalize_path(target_path);
  if strcmp(target, '/')
    node = info_struct;
    return;
  end

  try
    node = h5info(info_struct.Filename, target);
  catch ME
    error('locate_subtree:notFound', ...
          'Could not locate subtree at "%s": %s', target, ME.message);
  end
end

function values = search_Conf(config_item, fieldName, filterDir)
%SEARCH_CONF  Collect every value of a named field under filterDir.
%
%   values = search_Conf(config_item, fieldName, filterDir) walks the
%   config struct tree and collects every value of config_item.(fieldName)
%   whose config_item.path starts with filterDir.
%
%   Used by the additions auto-discovery to skip prop fields that are
%   already consumed by explicit config paths.

  values = walk(config_item, fieldName, filterDir, []);
end

function out = walk(node, fieldName, filterDir, out)
  if ~isstruct(node) || isempty(fieldnames(node))
    return;
  end

  if isfield(node, fieldName) && isfield(node, 'path')
    if iscell(node.path)
      for i = 1:length(node.path)
        if startsWith(node.path{i}, filterDir)
          out{end+1} = char(node.(fieldName));
        end
      end
    else
      if startsWith(node.path, filterDir)
        out{end+1} = char(node.(fieldName));
      end
    end
  end

  % Always recurse: matching a 'path' on this node does not mean its
  % children are not also matches.
  for f = fieldnames(node)'
    out = walk(node.(f{1}), fieldName, filterDir, out);
  end
end

%% Main functions

function [data, config_item] = readConf(info_struct, config_item, options)
% This function is the recursive engine behind loadEBSD_h5.
% It walks a config_item struct and turns it into either:
%   - a struct of raw HDF5 data, or
%   - the result of running a "name_type" formatter on that struct.

  arguments
    info_struct  struct
    config_item  struct
    options.root     string  = ""
    options.name     string  = ""
    options.multiple logical = false
    options.level    int8    = 1
    options.optional logical = false
  end

  % init struct cache keyed on the start of this function
  persistent cache_struct
  if options.level == 1
    cache_struct = struct();
  end

  data = [];

  % Phase 1 -- pull option overrides out of the config itself
  options = apply_config_overrides(options, config_item);

  % Phase 2 -- anchor the search to a "key" group if one is declared
  [options, skip] = resolve_root_path(info_struct, config_item, options);
  if skip
    return;
  end

  % Phase 3 -- read raw data from whichever source the config declares
  [raw_data, config_item] = fetch_raw_data(info_struct, config_item, options, cache_struct);

  % Phase 3.5 -- check if safe is set -> safe to cache
  if isfield(config_item, 'safe')
    cache_struct.(options.name) = raw_data;
  end

  % Phase 4 -- run a type-formatter if one is configured
  if isfield(config_item, 'type')
    data = apply_type_formatter(raw_data, config_item, options);
  else
    data = raw_data;
  end
end

function options = apply_config_overrides(options, config_item)
  fields = fieldnames(config_item);
  if ismember('optional', fields), options.optional = config_item.optional; end
  if ismember('multiple', fields), options.multiple = config_item.multiple; end
end

function [options, skip] = resolve_root_path(info_struct, config_item, options)
% If the config carries a 'key', locate the matching group in the HDF5
% file and make it the new root for every subsequent read in this branch.
  skip = false;
  if ~isfield(config_item, 'key'), return; end

  options.root = get_hdf5_path(info_struct, config_item.key, ...
    "root", options.root, ...
    "optional", options.optional);

  if options.root == ""
    vprintf(isDebug(), '   ⤴ skip optional "%s" (key resolved to empty)\n', options.name);
    skip = true;
  end
end

function [raw_data, config_item] = fetch_raw_data(info_struct, config_item, options, cach)
% The data source is implied by which top-level field the config item
% carries. Dispatch is exclusive: at most one of these can be present.
  if isfield(config_item, 'value')
    [raw_data, config_item] = fetch_from_path(info_struct, config_item, options);
  elseif isfield(config_item, 'data')
    raw_data = fetch_from_inline_data(config_item, options);
  elseif isfield(config_item, 'group')
    raw_data = fetch_from_group(info_struct, config_item, options);
  elseif isfield(config_item, 'load')
    raw_data = fetch_from_cache(config_item, cach, options);
  else
    [raw_data, config_item] = fetch_from_subfields(info_struct, config_item, options);
  end
end

function [raw_data, config_item] = fetch_from_cache(config_item, cache, options)
% The data was read elsewhere before and stored in the cache

  name = config_item.load.value;

  label = sprintf('├── %s', options.name);
  pathLabel = sprintf('[Load from cache field: "%s"]', name);
  print_debug(label, pathLabel, options.level);
  
  parts = split(name, '.');
  
  data = cache;
  for i = 1:numel(parts)
      data = data.(parts{i});
  end

  raw_data = data;

end

function [raw_data, config_item] = fetch_from_path(info_struct, config_item, options)
% The config points at one (or several) absolute / regex paths in the
% HDF5 file. The resolved path is stashed back on the config so that
% downstream code (e.g. the additions auto-discovery) can introspect it.
% A "fallback" value in the config is used whenever the path is missing -
% this makes an entry optional and still gives it a defined value.
  optional = options.optional || isfield(config_item, 'fallback');

  path = get_hdf5_path(info_struct, config_item, ...
    "root", options.root, ...
    "multiple", options.multiple, ...
    "optional", optional);
  config_item.path = path;

  % get_hdf5_path signals "not found" by an empty string, which isempty()
  % does not detect for a string scalar
  if ~iscell(path) && all(strlength(string(path)) == 0)
    label = sprintf('├── %s/', options.name);
    if isfield(config_item, 'fallback')
      pathLabel = sprintf('[Fallback value for "%s" (path not found)]', options.name);
      raw_data = config_item.fallback;
      % a "multiple" read hands a cell of values to the formatter - one
      % fallback value stands for all of them
      if options.multiple, raw_data = {raw_data}; end
    else
      pathLabel = sprintf('⤴ skip optional "%s" (path not found)\n', options.name);
      raw_data = struct();
    end
    print_debug(label, pathLabel, options.level);
    return;
  end

  if iscell(path)
    for pIdx = 1:length(path)
      label = sprintf('├── %s (%d)', options.name, pIdx);
      print_debug(label, string(path{pIdx}), options.level);
    end
  else
    label = sprintf('├── %s', options.name);
    print_debug(label, path, options.level);
  end

  raw_data = readData(info_struct.Filename, path);
end

function raw_data = fetch_from_inline_data(config_item, options)
% The data is shipped inside the JSON itself
  label = sprintf('├── %s', options.name);
  print_debug(label, '[Internal Config Data]', options.level);

  raw_data = config_item.data;
end

function raw_data = fetch_from_group(info_struct, config_item, options)
% Reads every dataset under a matched group at once, using the cleaned
% dataset name as the field name. Useful for header blobs and image
% bundles (FSE/SE). Under "multiple" one struct per matching group is
% returned, e.g. the atom positions of every phase.
  raw_data = struct();

  group_path = get_hdf5_path(info_struct, config_item.group, ...
    "root", options.root, ...
    "multiple", options.multiple, ...
    "optional", options.optional);
  config_item.path = group_path;

  if ~iscell(group_path) && all(strlength(string(group_path)) == 0)
    label = sprintf('├── %s/', options.name);
    pathLabel = sprintf('⤴ skip optional "%s" (group not found)\n', options.name);
    print_debug(label, pathLabel, options.level);
    return;
  end

  if ~iscell(group_path), group_path = {group_path}; end

  raw_data = cell(1,numel(group_path));
  for k = 1:numel(group_path)

    group = locate_subtree(info_struct, group_path{k});

    label = sprintf('├── %s/', options.name);
    pathLabel = sprintf('[Collect: %d Datasets] from %s', ...
      length(group.Datasets), group_path{k});
    print_debug(label, pathLabel, options.level);

    raw_data{k} = struct();
    for i = 1:length(group.Datasets)
      raw_name  = string(group.Datasets(i).Name);
      cleanName = validFieldName(clean_string(raw_name));
      raw_data{k}.(cleanName) = h5read(info_struct.Filename, group_path{k} + "/" + raw_name);
    end
  end

  if ~options.multiple, raw_data = raw_data{1}; end
end

function name = validFieldName(name)
% dataset names may start with a digit, e.g. the atoms of a Bruker phase
% are stored as AtomPositions/1, AtomPositions/2, ...
  name = char(name);
  if isempty(name) || ~isletter(name(1)), name = ['x' name]; end
end

function [raw_data, config_item] = fetch_from_subfields(info_struct, config_item, options)
% Each non-meta child is read recursively and merged back into a struct.
  label = sprintf('├── %s/', options.name);
  print_debug(label, '', options.level);

  raw_data = struct();
  meta_fields = ["key","type","multiple","optional"];
  fields = fieldnames(config_item);
  for i = 1:length(fields)
    currentfield = fields{i};
    if ismember(currentfield, meta_fields), continue; end

    [data_out, config_item.(currentfield)] = readConf( ...
      info_struct, config_item.(currentfield), ...
      "root",     options.root, ...
      "name",     currentfield, ...
      "multiple", options.multiple, ...
      "level",    options.level + 1);

    if isstruct(data_out) && isempty(fieldnames(data_out))
      % Empty -> nothing to merge, the optional read below silently
      % produced an empty struct.
      continue;
    end

    if options.multiple == true
      if iscell(data_out)
        c = cell(size(data_out));
        for j = 1:numel(data_out)
          s = struct();
          s.(currentfield) = data_out{j};
          c{j} = s;
        end
        raw_data = appendAndAlignCell(raw_data, c);
      else
        s = struct();
        s.(currentfield) = data_out;
        raw_data = appendAndAlignCell(raw_data, s);
      end
    else
      raw_data.(currentfield) = data_out;
    end
  end
end

function data = apply_type_formatter(raw_data, config_item, options)
% Convention: the formatter function must be named <options.name>_<type>.
% Errors during formatting are reported so a single broken formatter
% does not abort the entire load. Optional fields get an additional
% soft-fail gate: if the raw data is empty (because the upstream path
% was optional and missing), the formatter is not called at all.
  formatter_name = sprintf('%s_%s', options.name, config_item.type);
  label = sprintf('└── formatter: %s/', config_item.type);
  print_debug(label, '', options.level);

  data = struct();

  try
    formatter = str2func(formatter_name);
    if options.multiple == true
      data = format_multiple_results(formatter, raw_data, config_item);
    else
      data = format_single_result(formatter, raw_data, config_item);
    end
  catch ME
    warning('loadEBSD_h5:formatterError', ...
            'Formatter "%s" failed: %s', formatter_name, ME.message);
    vprintf(isDebug(), '%s\n', ME.getReport());
  end
end

function data = format_single_result(formatter, raw_data, config_item)
% If the subfields branch produced a struct that *also* has a field
% named after the type (e.g. the "direct" subfield of a position:direct
% config), hand the formatter just that subfield. Otherwise hand it
% the whole struct.
  if isfield(raw_data, config_item.type)
    data = formatter(raw_data.(config_item.type));
  else
    data = formatter(raw_data);
  end
end

function data = format_multiple_results(formatter, raw_data, config_item)
% Same dispatch rule, applied per cell element. This is what makes the
% "cs" / "phase" / "default" sub-configs work for multi-phase files.
  data = cell(1, length(raw_data));
  for i = 1:length(raw_data)
    if isfield(raw_data{i}, config_item.type)
      data{i} = formatter(raw_data{i}.(config_item.type));
    else
      data{i} = formatter(raw_data{i});
    end
  end
end

function outCell = appendAndAlignCell(oldCell, newInput)
% a helping function to merge two cells together a certain way

  if ~iscell(newInput)
    newInput = {newInput};
  end

  newInput = newInput(:)';
  newLen = numel(newInput);

  if isempty(oldCell) || isstruct(oldCell)
    outCell = newInput;
    return;
  end

  currentLen = numel(oldCell);

  if newLen > currentLen
    if currentLen == 1
      oldCell = repmat(oldCell, 1, newLen);
      currentLen = newLen;
    else
      error('Dimensions do not match: old %d elements, new %d elements.', currentLen, newLen);
    end
  elseif newLen < currentLen
    if newLen == 1
      newInput = repmat(newInput, 1, currentLen);
    else
      error('Dimensions do not match: old %d elements, new %d elements.', currentLen, newLen);
    end
  end

  outCell = oldCell;
  for i = 1:currentLen
    itemOld = oldCell{i};
    itemNew = newInput{i};

    if isstruct(itemOld) && isstruct(itemNew)
      fields = fieldnames(itemNew);
      for f = 1:numel(fields)
        itemOld.(fields{f}) = itemNew.(fields{f});
      end
      outCell{i} = itemOld;
    else
      outCell{i} = itemNew;
    end
  end
end
