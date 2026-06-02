function [ebsd] = loadEBSD_universal_hdf5(fname, varargin)

% How it is working:
%   - You load your file of hdf5 format
%   - The program will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes 
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object

% Selecting right config and load------------------------------------------

if ~exist(fname, 'file'), error('Datei %s nicht gefunden.', fname); end
info_struct = h5info(fname);

if check_option(varargin, 'debug')
  isDebug(get_option(varargin, 'debug'));
else
  isDebug(false);
end

if check_option(varargin, 'type')
  manufacturer = get_option(varargin, 'type');
else
  try
    manufacturer = string(h5read(fname, "/Manufacturer"));
  catch
    error("There was no readable manufacturer! " + ...
    "Try to specify which type of file you have. Use EBSD.load(yourdata, ""type"", ""yourType"")")
  end
end

% check all configs and select where manufacturer match
manufacturer = strrep(char(manufacturer), char(0), '');
folderPath = fullfile(mtex_path, 'interfaces', 'hdf5_config');

filePattern = fullfile(folderPath, '*.json');
fileList = dir(filePattern);

chosenjson = '';
for i = 1:length(fileList)

  if fileList(i).isdir
    continue;
  end
  
  baseFileName = fileList(i).name;
  fullFileName = fullfile(fileList(i).folder, baseFileName);

  jsonText = fileread(fullFileName);
  cur_Conf = jsondecode(jsonText);

  cur_manu = cur_Conf.settings.manufacturer_keys.data;

  if any(strcmpi(manufacturer, cur_manu))  

    chosenjson = fullFileName;
    break;

  end

end

if isempty(chosenjson)
  error("No Manufacturer config found for: " + manufacturer);
end

% read json config --> safe to file
try
  jsonText = fileread(chosenjson);
  Conf = jsondecode(jsonText);
catch ME
  error('Failed to load configuration: The file "%s" does not exist or contains invalid JSON. (Details: %s)', ...
        chosenjson, ME.message);
end

% generate config info text
fprintf('\n%s\n', repmat('═', 1, 80));
fprintf('HDF5 CONFIGURATION LOADED\n');
fprintf('├── Manufacturer : %s\n', Conf.settings.name);
if isfield(Conf.settings, 'manufacturer_info')
  wraptext(sprintf('    └── Info         : %s\n', Conf.settings.manufacturer_info.data));

end
fprintf('%s\n', repmat('═', 1, 80));

% Get absolute paths and load data-----------------------------------------

exclude = ["settings", "additions"];
data = struct();

categories = fieldnames(Conf);
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

% Construct prop-----------------------------------------------------------

prop = struct();

if isfield(Conf, 'additions')
  if Conf.additions.type == "auto"

    prop_path = get_hdf5_path(info_struct, Conf.additions.key, "mode", "groups");

    paths_allready_used = search_Conf(Conf, 'path', prop_path);
    
    [~, exclude_fields] = cellfun(@fileparts, paths_allready_used, 'UniformOutput', false);

    prop_node = locate_subtree(info_struct, prop_path);

    data_size = size(data.ebsd.pos);

    for i = 1:length(prop_node.Datasets)
      if prop_node.Datasets(i).Dataspace.Size == data_size(1)

        raw_name = prop_node.Datasets(i).Name;

        if ismember(raw_name, exclude_fields)
          continue;
        end

        clean_name = clean_string(raw_name);
        prop.(clean_name) = double(h5read(fname, prop_path + "/" + raw_name));

      end
    end
  else
    warning("Still to do when additions is not auto...")
  end
end

% Building output data-----------------------------------------------------

data.ebsd.prop = prop;

ebsd = data.ebsd;

end

% Formating functions------------------------------------------------------

function out = position_direct(raw_data)

  if ~isfield(raw_data, 'x') || ~isfield(raw_data, 'y')
    error('Position data has type direct but not the needed fields x and y')
  end

  out = vector3d(double(raw_data.x), double(raw_data.y), 0); 
  
end 

function out = position_indirect(raw_data)

  if ~isfield(raw_data, 'step_size_x') || ~isfield(raw_data, 'grid_size_x') ||... 
    ~isfield(raw_data, 'step_size_y') || ~isfield(raw_data, 'grid_size_y')

    error(['Position data has type indirect but not the needed fields ' ...
      'step_size_x, step_size_y, grid_size_x and grid_size_y'])
  end

  step_x = double(raw_data.step_size_x);
  step_y = double(raw_data.step_size_y);
  cells_x = double(raw_data.grid_size_x);
  cells_y = double(raw_data.grid_size_y);

  [x, y] = meshgrid(0:step_x:(cells_x-1)*step_x, 0:step_y:(cells_y-1)*step_y);

  out = vector3d(x(:), y(:), 0); 
end 

function out = rotation_euler(raw_data)

  fields = fieldnames(raw_data);
  
  if isempty(fields) || length(fields) > 4 || ~ismember('formate', fields)
    error(['Rotation data has type euler but not enough fields or too many' ...
      'field. You need to give 1-3 Fields and one named formate for degree or radiant formate.'])
  end

  formate = string(raw_data.formate);

  % Collect all fields and stick them together in one matrix
  matrix = cell(1, length(fields));
  for i = 1:length(fields)

    field_name = fields{i};

    if field_name == "formate"
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

  % Check if degree or radiant
  if formate == "degree"
    out = rotation.byEuler(phi * degree);
  elseif formate == "radiante"
    out = rotation.byEuler(phi);
  else 
    error('Wrong format for Rotation: "%s". Use "degree" or "radiante".', formate);  
  end
end 

function out = rotation_euler_stack(raw_data)

  if ~isfield(raw_data, 'phi') || ~isfield(raw_data, 'formate')
    error(['Rotation data has type euler_stack but not the correct fields where given!' ...
      ' Make sure you have phi and formate field.'])
  end

  formate = string(raw_data.formate);

  phi1_2D = raw_data.phi(1,:,:); 
  Phi_2D  = raw_data.phi(2,:,:);
  phi2_2D = raw_data.phi(3,:,:);

  % Check if degree or radiant
  if formate == "degree"
    out = rotation.byEuler(phi1_2D(:)*degree, Phi_2D(:)*degree, phi2_2D(:)*degree);
  elseif formate == "radiante"
    out = rotation.byEuler(phi1_2D(:), Phi_2D(:), phi2_2D(:));
  else 
    error('Wrong format for Rotation: "%s". Use "degree" or "radiante".', formate);  
  end
end

function out = cs_default(raw_data)

  if ~isfield(raw_data, 'space_group') || ~isfield(raw_data, 'lattice') || ~isfield(raw_data, 'name')
    error(['Cs data has type default but not the correct fields were given. ' ...
      'Make sure you have a group, lattice and name field!'])
  end

  out = crystalSymmetry( ...
    raw_data.space_group, ...
    raw_data.lattice.dim, ...
    raw_data.lattice.angle, ...
    'Mineral', ...
    raw_data.name);
end

function out = space_group_default(raw_data)

  if isnumeric(raw_data)
    clean = double(raw_data);
    cs = crystalSymmetry('spaceId', clean);
  else 
    clean = clean_string(raw_data);
    cs = crystalSymmetry(clean);
  end 
 
  out = cs.pointGroup;

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

function out = angle_seperate(raw_data)

  if ~isfield(raw_data, 'lattice_alpha') || ~isfield(raw_data, 'lattice_beta') || ~isfield(raw_data, 'lattice_gamma')
    error(['Cs angle data has type seperate but not the correct fields were given. ' ...
      'Make sure you have a lattice_alpha, lattice_beta and lattice_gamma!'])
  end

  alpha = double(raw_data.lattice_alpha)*degree;
  beta = double(raw_data.lattice_beta)*degree;
  gamma = double(raw_data.lattice_gamma)*degree;

  out = [alpha, beta, gamma];
end 

function out = dim_seperate(raw_data)

  if ~isfield(raw_data, 'lattice_a') || ~isfield(raw_data, 'lattice_b') || ~isfield(raw_data, 'lattice_c')
    error(['Cs angle data has type seperate but not the correct fields were given. ' ...
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

function out = rotation_correctById(raw_data)
% correct Euler angles such that the Euler angle reference frame coincides
% with the map reference frame

  if ~isfield(raw_data, 'correct_id') || ~isfield(raw_data, 'correct_data') || ~isfield(raw_data, 'rotation')
    error(['Rotation data has type correctById but not the correct fields were given. ' ...
      'Make sure you have a correct_id, correct_data and rotation!'])
  end

  id = double(raw_data.correct_id);
  data = double(raw_data.correct_data);
  rot = raw_data.rotation;

  correction = rotation.byEuler(data(id,:)*degree);

  out = correction .* rot;
  out.opt.correction = correction;

end

function out = rotation_correctByAngle(raw_data)

  if ~isfield(raw_data, 'angle') || ~isfield(raw_data, 'rotation')
    error(['Rotation data has type correctByAngle but not the correct fields were given. ' ...
      'Make sure you have a angle and rotation!'])
  end

  angle = double(raw_data.angle);
  rot = raw_data.rotation;

  correction = rotation.byAxisAngle(zvector, angle);

  out = correction .* rot;
  out.opt.correction = correction;

end

function out = ebsd_default(raw_data)

  if ~isfield(raw_data, 'position') || ~isfield(raw_data, 'phase') || ~isfield(raw_data, 'rotation') || ~isfield(raw_data, 'cs') 
    error(['EBSD data has not the correct fields! ' ...
      'Make sure you have a position, rotation, phase and cs field!'])
  end

  if ~isequal(numel(raw_data.position), numel(raw_data.rotation), numel(raw_data.phase))
    error('Array dimension mismatch! position (%d), rotation (%d), and phase (%d) must have the exact same number of elements.', ...
          numel(data.position), numel(data.rotation), numel(data.phase));
  end
  
  prop = struct();

  ebsd = EBSD(raw_data.position, raw_data.rotation, raw_data.phase, raw_data.cs, prop);
  
  % if a header was created add
  if isfield(raw_data, 'header')
    ebsd.opt.Header = raw_data.header;
  end

  out = ebsd;

end

% Functions----------------------------------------------------------------

function cleanName = clean_string(rawName, option)
arguments
  rawName 
  option = "full"
end
  rules = {
    '[ ,\-:|%~#\[\]()]', '';     
    'sub(?=\d)', '';
    'sub(?=[a-zA-Z])', '/';
    'ovl', '-';
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

function [data, config_item] = readConf(info_struct, config_item, options)

arguments
  info_struct struct
  config_item struct
  options.root string = ""
  options.name string = ""
  options.multiple logical = false
  options.level int8 = 1
end

  data = [];
  raw_data = struct();

  % return if and endpoint is reached
  if ~isstruct(config_item)
    return;
  end

  fields = fieldnames(config_item);

  % set a new root if key field is set --> root for all following iterations
  if ismember('key', fields)
    options.root = (get_hdf5_path(info_struct, config_item.key, "mode", "groups", "root", options.root));
  end

  % possibility to find multible --> important if more than one phase
  if ismember('multiple', fields)
    options.multiple = strcmpi(config_item.multiple, "true");
  end

  % the data is in a field to read from
  if ismember('value', fields)

    % generate absolute path and read data on this path
    path = get_hdf5_path(info_struct, config_item, "root", options.root, "multiple", options.multiple);
    config_item.path = path;
    
    % debug logic
    if iscell(path)
      for pIdx = 1:length(path)
        currentPath = string(path{pIdx});
        label = sprintf('├── %s (%d)', options.name, pIdx);
        print_debug(label, currentPath, options.level)
      end
    else
      label = sprintf('├── %s', options.name);
      print_debug(label, path, options.level)
    end
    
    % reading data 
    raw_data = readData(info_struct.Filename, path);

  % the data was given directly in json
  elseif ismember('data', fields)

    % debug logic
    label = sprintf('├── %s', options.name);
    print_debug(label, '[Internal Config Data]', options.level)

    % reading data
    raw_data = config_item.data;

  % the data is a whole group
  elseif any(strcmp('group', fields))

    % locate group in file
    group_path = get_hdf5_path(info_struct, config_item.group, "root", options.root, "mode", "groups");
    group = locate_subtree(info_struct, group_path);

    % debug logic
    label = sprintf('├── %s/', options.name);
    path = sprintf('[Collect: %d Datasets] from %s', length(group.Datasets), group_path);
    print_debug(label, path, options.level);

    % reading whole group data
    for i = 1:length(group.Datasets)
      raw_name = string(group.Datasets(i).Name);
      clean_name = clean_string(raw_name);
      raw_data.(clean_name) = h5read(info_struct.Filename, group_path + "/" + raw_name);
    end

  % the data is in a subfield
  else

    % debug logic
    label = sprintf('├── %s/', options.name);
    print_debug(label, '', options.level)

    % search all subfields for data
    for i = 1:length(fields)

      currentfield = fields{i};

      if currentfield=="key" || currentfield=="type" || currentfield=="multiple"
        continue;
      end

      [data_out, config_item.(currentfield)] = readConf( ...
        info_struct, ...
        config_item.(currentfield), ...
        "root", options.root, ...
        "name", currentfield, ...
        "multiple", options.multiple, ...
        "level", options.level + 1);
      
      if ~isempty(data_out)

        if options.multiple==true

          c = cell(size(data_out));
          for j = 1:numel(data_out)
            s = struct();
            s.(currentfield) = data_out{j};
            c{j} = s;
          end

          raw_data = appendAndAlignCell(raw_data,c);

        else
          raw_data.(currentfield) = data_out;
        end
      end
    end
  end
   
  % there is a type field use a formatter on collected data
  if ismember('type', fields)

    formatter_name = sprintf('%s_%s', options.name, config_item.type);

    % debug logic
    label = sprintf('└── formatter: %s/', config_item.type);
    print_debug(label, '', options.level)

    % call the formater with the data 
    try
      formatter = str2func(formatter_name);

      % if there are multiple data points call the formatter for each one
      if options.multiple==true

          data = cell(1, length(raw_data));
          for i = 1:length(raw_data)
            if isfield(raw_data{i}, config_item.type)
              data{i} = formatter(raw_data{i}.(config_item.type));
            else
              data{i} = formatter(raw_data{i});
            end
          end

      else
        if isfield(raw_data, config_item.type)
          data = formatter(raw_data.(config_item.type));
        else 
          data = formatter(raw_data);
        end
      end

    catch MS
      vprintf(isDebug(), '%s   [!] Formatter Error: %s\n', indent, formatter_name);
      disp(MS.getReport())
    end

  else
    data = raw_data;
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

function final_path = get_hdf5_path(info_struct, config_item, options)
% this function handles to find a path for a struct element with a value
% field 
arguments
  info_struct struct
  config_item struct
  options.root string = "/"
  options.mode string = "fields"
  options.multiple = false
end
  switch lower(config_item.mode)
    case 'absolute'
      final_path = config_item.value; 
          
    case 'regex'
      results = search_for_key(info_struct, config_item.value, options.mode, options.root);
      if isempty(results)
        error('No field found for key "%s"!', config_item.value);
      end
    
      if options.multiple == true
        final_path = results;
      else 
        final_path = results{1};
      end
    otherwise
      error('Unkown mode: %s. Only use regex or absolute', config_item.mode);
  end
end

function [paths] = search_for_key(info_struct, key, opt, startPath)
% searches for a given key in the hdf5 file, depending on the opt it
% searches for groups or fields with a start path
  arguments
    info_struct struct
    key string
    opt string
    startPath string = "/"
  end
  
  target_node = locate_subtree(info_struct, startPath);
  
  if isempty(target_node)
    warning('Path %s not found in meta data.', startPath);
    paths = {}; 
    return;
  end
  
  if opt=="groups"
    paths = search_recursive_groups(target_node, key, {});
  
  elseif opt=="fields"
    paths = search_recursive_fields(target_node, key, {});
  else 
    error("Unkown opt in search_for_key")
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
      error('Dimensionen passen nicht: Alt hat %d Elemente, Neu hat %d.', currentLen, newLen);
    end
  elseif newLen < currentLen
    if newLen == 1
      newInput = repmat(newInput, 1, currentLen);
    else
      error('Dimensionen passen nicht: Alt hat %d Elemente, Neu hat %d.', currentLen, newLen);
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

function matchNode = locate_subtree(node, targetPath)
% searches in a h5info struct to find a given path - returns the struct
% of the path

  tokensNode   = split(regexprep(node.Name, '^/+|/+$', ''), '/');
  tokensTarget = split(regexprep(targetPath, '^/+|/+$', ''), '/');
  
  tokensNode(cellfun(@isempty, tokensNode)) = [];
  tokensTarget(cellfun(@isempty, tokensTarget)) = [];
  
  if isequal(tokensNode, tokensTarget)
    matchNode = node;
    return;
  end
  
  matchNode = [];
  if ~isempty(node.Groups)
    for i = 1:length(node.Groups)
      groupName = node.Groups(i).Name;
      tokensGroup = split(regexprep(groupName, '^/+|/+$', ''), '/');
      tokensGroup(cellfun(@isempty, tokensGroup)) = [];
      
      lenGroup = length(tokensGroup);
      lenTarget = length(tokensTarget);
      
      if lenGroup <= lenTarget && isequal(tokensGroup, tokensTarget(1:lenGroup))
        matchNode = locate_subtree(node.Groups(i), targetPath);
        if ~isempty(matchNode)
          return;
        end
      end
    end
  end
end

function [paths] = search_recursive_groups(node, key, paths)
% searches in a h5info structs groups for a given key word - returns the
% path to the key

  if ~isempty(paths)
    return;
  end

  if contains(node.Name, key, 'IgnoreCase', true)
    paths{end+1} = node.Name; 
    return;
  end

  if ~isempty(node.Groups)
    for i = 1:length(node.Groups)
      paths = search_recursive_groups(node.Groups(i), key, paths);
      
      if ~isempty(paths)
        return; 
      end
    end
  end
end

function [paths] = search_recursive_fields(node, key, paths)
% searches in a h5info structs fields for a given key word - returns the
% path to the key

  % check if parent itself has a field with key
  if ~isempty(node.Datasets)
    for i = 1:length(node.Datasets)
   
      if ~isempty(regexpi(node.Datasets(i).Name, key, 'once'))

        if strcmp(node.Name, '/')
          fullPath = ['/' node.Datasets(i).Name];
        else
          fullPath = [node.Name '/' node.Datasets(i).Name];
        end
        paths{end+1} = fullPath;
      end
    end
  end

  % search fields of subgroups
  if ~isempty(node.Groups)
    for j = 1:length(node.Groups)
      paths = search_recursive_fields(node.Groups(j), key, paths);
    end
  end 
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

function data = search_Conf(config_item, value, filterDir, data)
% selects all nodes with value field from conf with a specific 'path' field

  if nargin < 4, data = {}; end
  if ~isstruct(config_item), return; end
  
  fields = fieldnames(config_item);
  
  if ismember(value, fields)
    if startsWith(config_item.path, filterDir)
        data{end+1} = config_item.(value); 
    end
  else 
    for i = 1:length(fields)
      data = search_Conf(config_item.(fields{i}), value, filterDir, data);
    end
  end
end