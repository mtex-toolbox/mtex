function [ebsd] = loadEBSD_universal_hdf5(fname, opt_file, varargin)

% How it is working:
%   - You load your file of hdf5 format
%   - The programm will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes 
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object


%--------Setting Options---------------------------------------------------

% Config struct mit Standartwerten füllen und dann nur die Werte ersetzten
% die explizit gesetzt wurden im json config file

defaultConf = struct;

defaultConf.settings.ebsd_key.mode = "regex";
defaultConf.settings.ebsd_key.value = "EBSD";

defaultConf.position.type = "direct";
defaultConf.position.direct.x.mode = "regex";
defaultConf.position.direct.x.value = "^X$";
defaultConf.position.direct.y.mode = "regex";
defaultConf.position.direct.y.value = "^Y$";

defaultConf.phase.type = "simple";
defaultConf.phase.simple.phase.mode = "regex";
defaultConf.phase.simple.phase.value = "^Phase$";

defaultConf.rotation.type = "euler";
defaultConf.rotation.euler.format = "radiant";
defaultConf.rotation.euler.phi.mode = "regex";
defaultConf.rotation.euler.phi.value = "euler";

defaultConf.cs.key.mode = "regex";
defaultConf.cs.key.value = "phase";
defaultConf.cs.type = "default";
defaultConf.cs.simple.group.mode = "regex";
defaultConf.cs.simple.group.value = "Space Group";
defaultConf.cs.simple.lattice.mode = "regex";
defaultConf.cs.simple.lattice.value = "^Lattice.*Dimension.$";
defaultConf.cs.simple.name.mode = "regex";
defaultConf.cs.simple.name.value = "Name";

%defaultConf.cs.folder_key = {"Phase", "Phases"};
%defaultConf.cs.lattice.dim_key = {"^Lattice.*Dimension.$", "^Lattice.*Constant.*_[abc]$"};
%defaultConf.cs.lattice.angle_key = {"^Lattice.*Constant.$", "^Lattice.*Angle.$","^Lattice.*Constant.*(alpha|beta|gamma)$"};

if ~exist(opt_file, 'file'), error('Datei %s nicht gefunden.', opt_file); end
if ~exist(fname, 'file'), error('Datei %s nicht gefunden.', fname); end

% read json config
jsonText = fileread(opt_file);
userConf = jsondecode(jsonText);

Conf = mergeConf(defaultConf, userConf);

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

  % skip if in exclude or no type field is found
  if ismember(cat, exclude) || ~isfield(Conf.(cat), 'type')
    continue;
  end 

  type = Conf.(cat).type;

  if ~isfield(Conf.(cat), type)
    error('You have definded a type in %s but no data was found', type);
  end 

  % preparing to go over each item in current categorie, collect raw data  
  fields = fieldnames(Conf.(cat).(type));
  raw_data = struct();

  % check if a subfolder earch key is set, works the same as with the ebsd
  % key --> look for subfolder and then only navigate within 
  key_path = "";
  if isfield(Conf.(cat), 'key')
    key_path = "/" + (get_hdf5_path(fname, Conf.(cat).key, "mode", "groups"));
  end

  for j = 1:length(fields)
    field_name = fields{j};

    % if there is no mode set in the field skip
    if ~isfield(Conf.(cat).(type).(field_name), "mode")
      continue;
    end

    foundPath = get_hdf5_path(fname, Conf.(cat).(type).(field_name), "root", ebsd_paths + key_path);
    Conf.(cat).(type).(field_name).path = foundPath;

    if ~isempty(foundPath)
      fprintf('Lade %s von %s...\n', field_name, foundPath);
  
      if 
      % if a path was found read from him and safe
      raw_data.(field_name) = h5read(fname, foundPath);

    else, warning("Konnte Pfad nicht finden!")
    end 
  end  

  % all the data from one categorie is collected and will be handed over
  % check if the type is simple, if this is the case use raw data (no formatter needed)
  if type=="simple"
    data.(cat) = raw_data;

  % if not construct a formatter name and look if one exists, if yes use it 
  else

    formatter_name = sprintf('%s_%s', cat, type);
  
    try
      formatter = str2func(formatter_name);
      data.(cat) = formatter(raw_data);
    catch
      error("Kein passender Formatierer gefunden!")
    end
  end
  disp("abgeschlossen: " + cat)
end 

jsonText = jsonencode(Conf, 'PrettyPrint', true);
disp(jsonText);

summary = structfun(@size, data, 'UniformOutput', false);
disp(summary);

end
% ---------Read data and convert to EBSD------------------------------------
% 
% 
%         skip non readable pictures (would cause a crash)
%         if ~(strcmp(sane_name,'Processed_Virtual_Forescatter_Detector_Images') || ...
%              strcmp(sane_name,'Unprocessed_Virtual_Forescatter_Detector_Images'))
% 
%             full_dataset_path = [data_info.Name '/' raw_name];            
%             EBSDdata.(sane_name) = double(h5read(fname, full_dataset_path));
%         end
%     end
% 
%     --------Load Data from Fields to EBSD object--------------------------
% 
%     Create pos ----------------------------------------------------------
%     x_field = get_field(fieldnames(EBSDdata), x_pos_fields);
%     y_field = get_field(fieldnames(EBSDdata), y_pos_fields);
%     pos = vector3d(EBSDdata.(x_field), EBSDdata.(y_field), 0); 
% 
%     Create phase---------------------------------------------------------
%     phase_field = get_field(fieldnames(EBSDdata), phase_fields);
%     phase = EBSDdata.(phase_field);
% 
%     Create rot-----------------------------------------------------------
%     rot_field = get_field(fieldnames(EBSDdata), rot_fields);
% 
%     check which format the rot is in
%     if contains(rot_field, 'phi', 'IgnoreCase', true)
% 
%         notIndexed = isappr(EBSDdata.phi1,4*pi,1e-5);
%         if all(EBSDdata.phi1(~notIndexed)<=2.001*pi) ...
%             && all(EBSDdata.Phi(~notIndexed)<=1.001*pi) ...
%             && all(EBSDdata.phi2(~notIndexed)<=2.001*pi)
% 
%             EBSDdata.phi1(notIndexed) = NaN;
%             EBSDdata.phi2(notIndexed) = NaN;
%             EBSDdata.Phi(notIndexed) = NaN;
% 
%             isDegree = 1;
%         else    
%             isDegree = degree;
%         end
% 
%         rot = rotation.byEuler(EBSDdata.phi1*isDegree, ...
%             EBSDdata.Phi*isDegree,EBSDdata.phi2*isDegree);
% 
%     elseif strcmpi(rot_field, "euler")
%         eulerData = EBSDdata.(rot_field)'; 
%         rot = rotation.byEuler(eulerData);
% 
%         safety check if matrix is correctly rotated
%         if size(rot, 2) > 1
%             rot = rot';
%         end
%     end
% 
%     Create CS------------------------------------------------------------
%     search for subfolder in ebsd folder with name 'Phases'
%     raw_phases_path = find_all_data(fname, phases_names, ebsd_paths{i});
%     current_phases_path = raw_phases_path{1};
% 
%     phase_info = h5info(fname, current_phases_path);
%     CS = cell(1, length(phase_info.Groups) + 1);
%     CS{1} = 'notIndexed';
% 
%     collect and cleanup data for each phase
%     for phase_n = 1:length(phase_info.Groups)
%         pN_data = struct;
%         current_group = phase_info.Groups(phase_n);
% 
%         read and cleanup each dataset per phase
%         for j = 1:length(current_group.Datasets)
%             sane_name = standardize_field(current_group.Datasets(j).Name);
%             ds_path = [current_group.Name '/' current_group.Datasets(j).Name];
% 
%             check for Laue_Group name because this data is stored
%             differently
%             if strcmpi(sane_name, 'Laue_Group')
%                 pN_data.Laue_Group = current_group.Datasets(j).Attributes.Value;
%             else
%                 pN_data.(sane_name) = h5read(fname, ds_path);
%             end
%         end
% 
%         create symmetrie object
%         try
%             if isfield(pN_data, 'Space_Group') && pN_data.Space_Group ~= 0
%                 csm = crystalSymmetry('SpaceId', pN_data.Space_Group);
%             else
%                 csm = crystalSymmetry(pN_data.Laue_Group);
%             end
%         catch
%             csm = crystalSymmetry('m-3m'); % default
%         end
% 
%         build angle and dimension
%         lattice_field = get_field(fieldnames(pN_data), lattice_angle_fields);
% 
%         if length(lattice_field) == 3
%             langle = [double(pN_data.(lattice_field{1})(:)'); 
%                 double(pN_data.(lattice_field{2})(:)');
%                 double(pN_data.(lattice_field{3})(:)')];
%         elseif ~iscell(lattice_field)
%             langle = double(pN_data.(lattice_field)(:));
%         else
%             error("The phase angle was not readable!")
%         end
% 
%         correcting all rounding errors
%         if strcmpi(csm.lattice, 'trigonal') || strcmpi(csm.lattice, 'hexagonal')
%             langle(abs(langle - 120*degree) < 0.01) = 120*degree;
%         else
%             langle(abs(langle - 90*degree) < 0.01) = 90*degree;
%         end
% 
%         check how lattice variables are stored
%         if length(langle) > 5
%             dimension = double(langle(1:3));
%             angles = double(langle(4:6))*degree;
%         else 
%             angles = langle;
%             dimension_field = get_field(fieldnames(pN_data), lattice_dim_fields);
% 
%             if length(dimension_field) == 3
%                 dimension = [double(pN_data.(dimension_field{1})(:));
%                     double(pN_data.(dimension_field{2})(:));
%                     double(pN_data.(dimension_field{3})(:))];
%             elseif ~iscell(dimension_field)
%                 dimension = double(pN_data.(dimension_field)(:));
%             else 
%                 error("The phase dimension was not readable!")
%             end 
%         end
% 
%         get phase names
%         phase_name_field = get_field(fieldnames(pN_data), {"Phase_Name", "Name"});
%         name = char(pN_data.(phase_name_field));
% 
%         build final cs object
%         CS{phase_n + 1} = crystalSymmetry( ...
%             csm.pointGroup, ...
%             dimension, ...
%             angles, ...
%             'Mineral', ...
%             name);
% 
%     fix phase names
%     phaseNames = cellfun(@(x) string(x.mineral), CS(2:end));
%     phaseNames = makeDisjoint(phaseNames);
%     for p_idx = 2:length(CS)
%         CS{p_idx}.mineral = char(phaseNames(p_idx-1));
%     end
% 
%     Create opt-----------------------------------------------------------
%     opt = struct;
%     optList_std  = {'X' 'Y' 'Band_Contrast' 'Band_Slope' 'Bands' 'Mean_Angular_Deviation' 'Pattern_Quality'};
%     optNames_std = {'x' 'y' 'bc' 'bs' 'bands' 'MAD' 'quality'};
% 
%     populate opt and skip unkown 
%     for jj = 1:length(optNames_std)
%         try
%             opt.(optNames_std{jj}) = EBSDdata.(optList_std{jj});
%         catch
%             continue
%         end 
%     end
% 
%     Build EBSD-----------------------------------------------------------
%     ebsd_temp{i} = EBSD(pos, rot, phase, CS, opt);
% 
% if length(ebsd_temp) > 1
%     ebsd = ebsd_temp;
% else 
%     ebsd = ebsd_temp{1};
% end
% end 
% end
% Formating functions------------------------------------------------------

function out = position_direct(raw_data)

  out = vector3d(raw_data.x, raw_data.y, 0); 
  
end 

function out = rotation_euler(raw_data)
  matrix = {};
  fields = fieldnames(raw_data);
  for i = 1:length(fields)

    [h, w] = size(raw_data.(fields{i}));

    if h > w
      matrix{end+1} = raw_data.(fields{i});
    else
      matrix{end+1} = (raw_data.(fields{i}))';
    end
  end 

  phi = horzcat(matrix{:});

  if max(phi, [], 'all') > 2*pi
    out = rotation.byEuler(phi, 'degree');
  else
    out = rotation.byEuler(phi);
  end
end 

%-----------Functions------------------------------------------------------
function [standardName] = standardize_field(foundField)
    rules = {
        '[ ,\-:|%~#]', '_';     
        '^x$|x_beam|pos_x|X_Position', 'X';
        '^y$|y_beam|pos_y|Y_Position', 'Y';
        'phi', 'Phi';
        'phi1', 'phi1';
        'phi2', 'phi2'
    };

    standardName = foundField;
    for r = 1:size(rules, 1)
        standardName = regexprep(standardName, rules{r, 1}, rules{r, 2}, 'ignorecase');    
    end
end

function final_path = get_hdf5_path(fname, config_item, options)
arguments
  fname string
  config_item struct
  options.root string = "/"
  options.mode string = "fields"
end

    switch lower(config_item.mode)
        case 'absolute'
            final_path = config_item.value; 
            
        case 'regex'
            results = search_for_key(fname, config_item.value, options.mode, options.root);
            if isempty(results)
                error('Kein Feld für Suchbegriff "%s" gefunden!', config_item.value);
            end
            final_path = results{1}; % Den ersten Treffer nehmen
            
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

function [foundFields] = get_field(fields, keys)
    arguments
        fields cell
        keys cell
    end
    
    finalMask = false(size(fields));
    
    for i = 1:length(keys)
        res = regexpi(fields, keys{i});
        currentMask = ~cellfun(@isempty, res);
        finalMask = finalMask | currentMask; 
    end
    
    foundFields = fields(finalMask);

    if isempty(foundFields)
        foundFields = {};
    elseif isscalar(foundFields)
        foundFields = foundFields{1};
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