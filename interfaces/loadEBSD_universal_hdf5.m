function [ebsd] = loadEBSD_universal_hdf5(fname, opt_file, varargin)

% How it is working:
%   - You load your file of hdf5 format
%   - The programm will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes 
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object


%--------Setting Options---------------------------------------------------
if ~exist(fname, 'file'), error('Datei %s nicht gefunden.', fname); end
if ~exist(opt_file, 'file'), error('Json %s nicht gefunden.', fname); end

% read json config
jsonText = fileread(opt_file);
Conf = jsondecode(jsonText);

summary = structfun(@size, Conf, 'UniformOutput', false);
disp(summary);

%---------Search for data folders and get paths----------------------------

if isfield(Conf.settings, "ebsd_key")
  
  ebsd_paths = get_hdf5_path(fname, Conf.settings.ebsd_key, "mode", "groups");
  disp(ebsd_paths)
  if isempty(ebsd_paths)
      error("There was no EBSD Dataset found!");
  end 

end 

% Get absolute paths and load data-----------------------------------------

exclude = {'settings', 'additions'};

% preparing struct for final data
data = struct();

% loop into every categorie
categories = fieldnames(Conf);
for i = 1:length(categories)
  
  cat = categories{i};

  if ismember(cat, exclude)
    continue;
  end

  [data.(cat), Conf.(cat)] = readConf(fname, Conf.(cat), ebsd_paths, cat, false);

  disp("Completed: " + cat);
end

%jsonText = jsonencode(Conf, 'PrettyPrint', true);
%disp(jsonText);

summary = structfun(@size, data, 'UniformOutput', false);
disp(summary);

% Construct prop-----------------------------------------------------------

prop = struct();

if isfield(Conf, 'additions')

  if Conf.additions.type == "auto"

    prop_path = get_hdf5_path(fname, Conf.additions.key, "mode", "groups", "root", ebsd_paths);
    raw_fields_names = h5info(fname, prop_path);
    data_size = size(data.position);
    for i = 1:length(raw_fields_names.Datasets)
      if raw_fields_names.Datasets(i).Dataspace.Size == data_size(1)
        raw_name = raw_fields_names.Datasets(i).Name;
        clean_name = clean_string(raw_name);
        prop.(clean_name) = h5read(fname, prop_path + "/" + raw_name);
      end
    end
  else

  end
end

numPos = size(data.position, 1);
numOri = size(data.rotation, 1);
fprintf('Positionen: %d, Orientierungen: %d\n', numPos, numOri);

ebsd = EBSD(data.position, data.rotation, data.phase, data.cs, prop);



end

% Formating functions------------------------------------------------------

function out = position_direct(raw_data)

 % out = [double(raw_data.direct.x(:)), double(raw_data.direct.y(:))];
  out = vector3d(double(raw_data.direct.x), double(raw_data.direct.y), 0); 
  
end 

function out = position_indirect(raw_data)

  if ~isfield(raw_data.indirect, 'step_size') || ~isfield(raw_data.indirect, 'grid_size')
    error('Position data has type indirect but not the needed fields step_size and grid_size')
  end

  stepSize = double(raw_data.indirect.step_size);
  [ny, nx] = size(raw_data.indirect.grid_size);

  [x, y] = meshgrid(0:stepSize:(nx-1)*stepSize, 0:stepSize:(ny-1)*stepSize);

  out = vector3d(x(:), y(:), 0); 
end 

function out = rotation_euler(raw_data)
  fields = fieldnames(raw_data.euler);
  matrix = cell(1, length(fields));
  for i = 1:length(fields)

    [h, w] = size(raw_data.euler.(fields{i}));

    if h > w
      matrix{i} = double(raw_data.euler.(fields{i}));
    else
      matrix{i} = double((raw_data.euler.(fields{i}))');
    end
  end 

  phi = horzcat(matrix{:});

  if max(phi, [], 'all') > 2*pi
    out = rotation.byEuler(phi * degree);
  else
    out = rotation.byEuler(phi);
  end
end 

function out = rotation_euler_stack(raw_data)

  disp(size(raw_data.euler_stack.phi))

  phi1_2D = raw_data.euler_stack.phi(1,:,:); 
  Phi_2D  = raw_data.euler_stack.phi(2,:,:);
  phi2_2D = raw_data.euler_stack.phi(3,:,:);

  % 2. In 310x1 Vektoren umwandeln und das rotation-Objekt bauen
  % Der (:) Operator wandelt die 10x31 Matrix in eine 310x1 Spalte um
  
  if max(Phi_2D, [], 'all') > 2*pi
    out = rotation.byEuler(phi1_2D(:)*degree, Phi_2D(:)*degree, phi2_2D(:)*degree);
  else 
    out = rotation.byEuler(phi1_2D(:), Phi_2D(:), phi2_2D(:));
  end

  disp(length(out))

end

function out = cs_default(raw_data)

  summary = structfun(@size, raw_data.default, 'UniformOutput', false);
  disp(summary);

  out = crystalSymmetry( ...
    raw_data.default.group, ...
    raw_data.default.lattice.dim, ...
    raw_data.default.lattice.angle, ...
    'Mineral', ...
    raw_data.default.name);

end

function out = group_space(raw_data)

  if isnumeric(raw_data)
    clean = double(raw_data);
    cs = crystalSymmetry('spaceId', clean);

  else 
    clean = clean_string(raw_data);
    cs = crystalSymmetry(clean);
  end 
 
  disp("PointGroup: " + cs.pointGroup);
  out = cs.pointGroup;

end

function out = lattice_all_together(raw_data)

  dimension = double(raw_data(1:3));
  angles = double(raw_data(4:6))*degree;

  out = struct();
  out.dim = dimension;
  out.angle = angles;
  
end

function out = angle_seperate(raw_data)

  alpha = double(raw_data.lattice_alpha)*degree;
  beta = double(raw_data.lattice_beta)*degree;
  gamma = double(raw_data.lattice_gamma)*degree;

  out = [alpha, beta, gamma];

end 

function out = dim_seperate(raw_data)

  a = double(raw_data.lattice_a);
  b = double(raw_data.lattice_b);
  c = double(raw_data.lattice_c);

  out = [a, b, c];

end 

function out = phase_stack(raw_data)

  out = raw_data(:);

end


%-----------Functions------------------------------------------------------
function cleanName = clean_string(rawName, option)
arguments
  rawName 
  option = "full"
end
    rules = {
        '[ ,\-:|%~#]', '';     
        'sub', '/';
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

function [data, config_item] = readConf(fname, config_item, root, name, multiple)

  data = [];
  raw_data = struct();

  if ~isstruct(config_item)
    return;
  end

  fields = fieldnames(config_item);

  if ismember('key', fields)
    root = (get_hdf5_path(fname, config_item.key, "mode", "groups", "root", root));
  end

  if ismember('multiple', fields)
    multiple = strcmpi(config_item.multiple, "true");
    disp("New multi: " + multiple)
  end

  if ismember('value', fields)
    path = get_hdf5_path(fname, config_item, "root", root, "multiple", multiple);
    config_item.path = path;
    disp("Lade " + string(name) + " von " + string(path) + "...");    
    raw_data = readData(fname, path);
  else

    for i = 1:length(fields)
      currentfield = fields{i};

      if currentfield=="key"
        continue;
      end

      [data_out, config_item.(currentfield)] = readConf(fname, config_item.(currentfield), root, currentfield, multiple);

      if ~isempty(data_out)
        if iscell(data_out)
          % FALL A: Wir haben mehrere Datensätze (z.B. Phasen)
          % Falls raw_data noch ein einfaches Struct ist, wandle es in eine Cell-Liste um
          if ~iscell(raw_data)
            raw_data = cell(size(data_out));
            for k = 1:length(raw_data), raw_data{k} = struct(); end
          end
          
          % Mergen: Füge das Feld zu jedem existierenden Phasen-Struct hinzu
          for j = 1:length(data_out)
            % WICHTIG: Nutze j (Index der Daten/Phase), nicht i (Index des Feldes)!
            raw_data{j}.(currentfield) = data_out{j};
          end       
        else
          % FALL B: Einzelner Datensatz
          if iscell(raw_data)
            % Wenn wir schon Phasen-Zellen haben, kopiere den Einzelwert in alle
            for j = 1:length(raw_data), raw_data{j}.(currentfield) = data_out; end
          else
            raw_data.(currentfield) = data_out;
          end
        end
      end
    end
  end
   
  if ismember('type', fields)

    formatter_name = sprintf('%s_%s', name, config_item.type);
    disp("Formatter: " + formatter_name);
    try
      formatter = str2func(formatter_name);
      if iscell(raw_data)
        data = cell(1, length(raw_data));
        for i = 1:length(raw_data)
          data{i} = formatter(raw_data{i});
        end
      else
        data = formatter(raw_data);
      end
    catch MS
      errorMsg = getReport(MS);
      disp(errorMsg);
    end
  else
    data = raw_data;
  end
end

function data = readData(fname, paths)

  if iscell(paths)
    data = cell(1, length(paths));
    for i = 1:length(paths)
      data{i} = h5read(fname, paths{i});
    end
    disp(data)
  else 
    data = h5read(fname, paths);
  end
end 

function final_path = get_hdf5_path(fname, config_item, options)
arguments
  fname string
  config_item struct
  options.root string = "/"
  options.mode string = "fields"
  options.multiple = false
end
  switch lower(config_item.mode)
      case 'absolute'
          final_path = config_item.value; 
          
      case 'regex'
          results = search_for_key(fname, config_item.value, options.mode, options.root);
          if isempty(results)
              error('Kein Feld für Suchbegriff "%s" gefunden!', config_item.value);
          end

          if options.multiple == true
            final_path = results;
          else 
            final_path = results{1};
          end
      otherwise
          error('Unbekannter Modus: %s', config_item.mode);
  end
end

function [paths] = search_for_key(fname, key, opt, startPath)
    arguments
        fname string
        key string
        opt string
        startPath string = "/"
    end
    
    try
        root = h5info(fname, startPath);
    catch
        warning('Pfad %s nicht gefunden.', startPath);
        paths = {}; return;
    end
    if opt=="groups"
      paths = search_recursive_groups(root, key, {});

    elseif opt=="fields"
      paths = search_recursive_fields(root, key, {});
    else 
      error("Unkown opt in search_for_key")
    end
end

function [paths] = search_recursive_groups(node, key, paths)
    % Falls bereits ein Treffer in einem vorherigen Zweig gefunden wurde: Abbruch
    if ~isempty(paths)
        return;
    end

    % 1. Prüfen, ob der aktuelle Knoten selbst passt
    if contains(node.Name, key, 'IgnoreCase', true)
        paths{end+1} = node.Name; 
        return; % Treffer gefunden, Rekursion für diesen Zweig stoppen
    end

    % 2. Untergruppen durchsuchen
    if ~isempty(node.Groups)
        for i = 1:length(node.Groups)
            paths = search_recursive_groups(node.Groups(i), key, paths);
            
            % KRITISCH: Sofort abbrechen, wenn die Untergruppe einen Treffer geliefert hat
            if ~isempty(paths)
                return; 
            end
        end
    end
end

function [paths] = search_recursive_fields(node, key, paths)

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