function [ebsd] = loadEBSD_universal_hdf5(fname, opt_file, varargin)

% How it is working: todo
%   - You load your file of hdf5 format
%   - The programm will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes 
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object


%--------Setting Options---------------------------------------------------

% Config struct mit Standartwerten füllen und dann nur die Werte ersetzten
% die explizit gesetzt wurden im json config file


if ~exist(fname, 'file'), error('Datei %s nicht gefunden.', fname); end

% read json config
jsonText = fileread(opt_file);
Conf = jsondecode(jsonText);

summary = structfun(@size, Conf.rotation.euler, 'UniformOutput', false);
disp(summary);

%---------Search for data and get paths------------------------------------

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

  [data.(cat), Conf.(cat)] = readConf(fname, Conf.(cat), ebsd_paths, cat);

  disp("Completed: " + cat);
end

%   % skip if in exclude or no type field is found
%   if ismember(cat, exclude) || ~isfield(Conf.(cat), 'type')
%     continue;
%   end 
% 
%   type = Conf.(cat).type;
% 
%   if ~isfield(Conf.(cat), type)
%     error('You have definded a type in %s but no data was found', type);
%   end 
% 
%   % preparing to go over each item in current categorie, collect raw data  
%   fields = fieldnames(Conf.(cat).(type));
%   raw_data = struct();
% 
%   % check if a subfolder earch key is set, works the same as with the ebsd
%   % key --> look for subfolder and then only navigate within 
%   key_path = "";
%   if isfield(Conf.(cat), 'key')
%     key_path = "/" + (get_hdf5_path(fname, Conf.(cat).key, "mode", "groups"));
%   end
% 
%   for j = 1:length(fields)
%     field_name = fields{j};
% 
%     % if there is no mode set in the field skip
%     if ~isfield(Conf.(cat).(type).(field_name), "mode")
%       continue;
%     end
% 
%     foundPath = get_hdf5_path(fname, Conf.(cat).(type).(field_name), "root", ebsd_paths + key_path);
%     Conf.(cat).(type).(field_name).path = foundPath;
% 
%     if ~isempty(foundPath)
%       fprintf('Lade %s von %s...\n', field_name, foundPath);
% 
%       raw_data.(field_name) = h5read(fname, foundPath);
% 
%       if isfield(Conf.(cat).(type).(field_name), 'formate')
% 
%         sub_formatter_name = sprintf('%s_%s_%s', cat, type, field_name);
% 
%         try
%           sub_formatter = str2func(sub_formatter_name);
%           raw_data.(field_name) = sub_formatter(raw_data.(field_name));
%         catch
%           error("Kein passender Sub_Formatierer gefunden!")
%         end
% 
%       end 
% 
%     else, warning("Konnte Pfad nicht finden!")
%     end 
%   end  
% 
%   % all the data from one categorie is collected and will be handed over
%   % check if the type is simple, if this is the case use raw data (no formatter needed)
%   if type=="simple"
%     data.(cat) = raw_data;
% 
%   % if not construct a formatter name and look if one exists, if yes use it 
%   else
% 
%     formatter_name = sprintf('%s_%s', cat, type);
% 
%     try
%       formatter = str2func(formatter_name);
%       data.(cat) = formatter(raw_data);
%     catch
%       error("Kein passender Formatierer gefunden!")
%     end
%   end
%   disp("abgeschlossen: " + cat)
% end 

%jsonText = jsonencode(Conf, 'PrettyPrint', true);
%disp(jsonText);

summary = structfun(@size, data, 'UniformOutput', false);
disp(summary);

prop = struct();

ebsd = EBSD(data.position, data.rotation, data.phase, data.cs, prop);



end

% Formating functions------------------------------------------------------

function out = position_direct(raw_data)

 % out = [double(raw_data.direct.x(:)), double(raw_data.direct.y(:))];
  out = vector3d(double(raw_data.direct.x), double(raw_data.direct.y), 0); 
  
end 

% function out = position_indirect(raw_data)
% 
%   if ~isfield(raw_data, 'step_size') || ~isfield(raw_data, 'grid_size')
%     error('Position data has type indirect but not the needed fields step_size and grid_size')
%   end
% 
%   [h, w] = size(raw_data.grid_size);
% 
%   [x, y] = meshgrid(0; raw_data.);
% 
% end 

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

function out = cs_default(raw_data)

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
    disp(clean)
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

function out = angle_all_together(raw_data)

  out = raw_data;

end

function out = dim_all_together(raw_data)

  out = raw_data;

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


%-----------Functions------------------------------------------------------
function cleanName = clean_string(rawName)
    rules = {
        '[ ,\-:|%~#]', '';     
        'sub', '';
        'ovl', '';
    };

    cleanName = rawName;

    for r = 1:size(rules, 1)
        cleanName = regexprep(cleanName, rules{r, 1}, rules{r, 2}, 'ignorecase');    
    end
end

function [data, config_item] = readConf(fname, config_item, root, name)

  data = [];
  raw_data = struct();

  if ~isstruct(config_item)
    return;
  end

  fields = fieldnames(config_item);

  if ismember('key', fields)
    root = (get_hdf5_path(fname, config_item.key, "mode", "groups", "root", root));
  end

  if ismember('value', fields)

    path = get_hdf5_path(fname, config_item, "root", root);
    config_item.path = path;
    fprintf('Lade %s von %s...\n', name, path);
    raw_data = h5read(fname, path);
    
  else

    for i = 1:length(fields)
      currentfield = fields{i};

      if currentfield=="key"
        continue;
      end

      [data_out, config_item.(currentfield)] = readConf(fname, config_item.(currentfield), root, currentfield);

      if ~isempty(data_out)
        fprintf('Saving to %s...\n', currentfield);
        raw_data.(currentfield) = data_out;
      end

    end
  end
   
  if ismember('type', fields)

    formatter_name = sprintf('%s_%s', name, config_item.type);
    disp("Formatter: " + formatter_name);
    try
      formatter = str2func(formatter_name);
      data = formatter(raw_data);
    catch MS
      errorMsg = getReport(MS);
      disp(errorMsg);
    end
  else
    data = raw_data;
  end
end

function final_path = get_hdf5_path(fname, config_item, options)
arguments
  fname string
  config_item struct
  options.root string = "/"
  options.mode string = "fields"
  options.multiple bool = false
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

function default = mergeConf(default, user)

  if isempty(user)
    return
  end 

  fields = fieldnames(user);

  for i = 1:length(fields)
    f = fields{i};
    if isfield(default, f) && isstruct(default.(f)) && isstruct(user.(f))
      default.(f) = mergeConf(default.(f), user.(f));
    else 
      default.(f) = user.(f);
    end
  end
end 