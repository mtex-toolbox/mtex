function [ebsd] = loadEBSD_universal_hdf5(fname, varargin)

% How it is working:
%   - You load your file of hdf5 format
%   - The programm will try to find groups with certain codes like EBSD --> if there is no such data an error is thrown
%   - One can modify the search codes 
%   - The data will be extracted using an algorithm fitted to the data
%   - There are helper functions to convert data and build the EBSD object


x_pos_fields = {"^X$",};
y_pos_fields = {"^Y$",};
rot_fields = {"^Euler$", "^Phi$"};
lattice_angle_fields = {"^Lattice.*Constant.$", "^Lattice.*Angle.$","^Lattice.*Constant.*(alpha|beta|gamma)$"};
lattice_dim_fields = {"^Lattice.*Dimension.$", "^Lattice.*Constant.*_[abc]$"};
phase_fields = {"^Phase$"};

phases_names = {"Phase", "Phases"};
ebsd_names = {"EBSD"};

if ~exist(fname, 'file'), error('Datei %s nicht gefunden.', fname); end

%---------Search for data--------------------------------------------------

ebsd_paths = find_all_data(fname, ebsd_names);

if isempty(ebsd_paths)
    error("There was no EBSD Dataset found!");
end 

ebsd_temp = {};

%---------Read data and convert to EBSD------------------------------------

for i = 1:length(ebsd_paths)
    try
    % search for subfolders named 'Data' and catch if there are none
    raw_data_paths = find_all_data(fname, 'Data', ebsd_paths{i});
    
    if isempty(raw_data_paths)
        fprintf('No data found in %s. Skiping...\n', ebsd_paths{i});
        continue;
    end
    
    % take the first found data path and prepare to read from file to
    % struct
    current_data_path = raw_data_paths{1};
    data_info = h5info(fname, current_data_path);
    EBSDdata = struct;
    
    % iterate over all datasets and cleanup before read
    for thing = 1:length(data_info.Datasets)

        raw_name = data_info.Datasets(thing).Name;
        sane_name = standardize_field(raw_name);

        % disp(raw_name + " : " + sane_name);
        
        % skip non readable pictures (would cause a crash)
        if ~(strcmp(sane_name,'Processed_Virtual_Forescatter_Detector_Images') || ...
             strcmp(sane_name,'Unprocessed_Virtual_Forescatter_Detector_Images'))
           
            full_dataset_path = [data_info.Name '/' raw_name];            
            EBSDdata.(sane_name) = double(h5read(fname, full_dataset_path));
        end
    end
    
    %--------Load Data from Fields to EBSD object--------------------------
    
    % Create pos ----------------------------------------------------------
    x_field = get_field(fieldnames(EBSDdata), x_pos_fields);
    y_field = get_field(fieldnames(EBSDdata), y_pos_fields);
    pos = vector3d(EBSDdata.(x_field), EBSDdata.(y_field), 0); 

    % Create phase---------------------------------------------------------
    phase_field = get_field(fieldnames(EBSDdata), phase_fields);
    phase = EBSDdata.(phase_field);

    % Create rot-----------------------------------------------------------
    rot_field = get_field(fieldnames(EBSDdata), rot_fields);
    
    % check which format the rot is in
    if contains(rot_field, 'phi', 'IgnoreCase', true)

        notIndexed = isappr(EBSDdata.phi1,4*pi,1e-5);
        if all(EBSDdata.phi1(~notIndexed)<=2.001*pi) ...
            && all(EBSDdata.Phi(~notIndexed)<=1.001*pi) ...
            && all(EBSDdata.phi2(~notIndexed)<=2.001*pi)
          
            EBSDdata.phi1(notIndexed) = NaN;
            EBSDdata.phi2(notIndexed) = NaN;
            EBSDdata.Phi(notIndexed) = NaN;
      
            isDegree = 1;
        else    
            isDegree = degree;
        end

        rot = rotation.byEuler(EBSDdata.phi1*isDegree, ...
            EBSDdata.Phi*isDegree,EBSDdata.phi2*isDegree);

    elseif strcmpi(rot_field, "euler")
        eulerData = EBSDdata.(rot_field)'; 
        rot = rotation.byEuler(eulerData);
        
        % safety check if matrix is correctly rotated
        if size(rot, 2) > 1
            rot = rot';
        end
    end
 
    % Create CS------------------------------------------------------------
    % search for subfolder in ebsd folder with name 'Phases'
    raw_phases_path = find_all_data(fname, phases_names, ebsd_paths{i});
    current_phases_path = raw_phases_path{1};
    
    phase_info = h5info(fname, current_phases_path);
    CS = cell(1, length(phase_info.Groups) + 1);
    CS{1} = 'notIndexed';

    % collect and cleanup data for each phase
    for phase_n = 1:length(phase_info.Groups)
        pN_data = struct;
        current_group = phase_info.Groups(phase_n);
        
        % read and cleanup each dataset per phase
        for j = 1:length(current_group.Datasets)
            sane_name = standardize_field(current_group.Datasets(j).Name);
            ds_path = [current_group.Name '/' current_group.Datasets(j).Name];
            
            % check for Laue_Group name because this data is stored
            % differently
            if strcmpi(sane_name, 'Laue_Group')
                pN_data.Laue_Group = current_group.Datasets(j).Attributes.Value;
            else
                pN_data.(sane_name) = h5read(fname, ds_path);
            end
        end

        % create symmetrie object
        try
            if isfield(pN_data, 'Space_Group') && pN_data.Space_Group ~= 0
                csm = crystalSymmetry('SpaceId', pN_data.Space_Group);
            else
                csm = crystalSymmetry(pN_data.Laue_Group);
            end
        catch
            csm = crystalSymmetry('m-3m'); % default
        end

        % build angle and dimension
        lattice_field = get_field(fieldnames(pN_data), lattice_angle_fields);

        if length(lattice_field) == 3
            langle = [double(pN_data.(lattice_field{1})(:)'); 
                double(pN_data.(lattice_field{2})(:)');
                double(pN_data.(lattice_field{3})(:)')];
        elseif ~iscell(lattice_field)
            langle = double(pN_data.(lattice_field)(:));
        else
            error("The phase angle was not readable!")
        end

        % correcting all rounding errors
        if strcmpi(csm.lattice, 'trigonal') || strcmpi(csm.lattice, 'hexagonal')
            langle(abs(langle - 120*degree) < 0.01) = 120*degree;
        else
            langle(abs(langle - 90*degree) < 0.01) = 90*degree;
        end

        % check how lattice variables are stored
        if length(langle) > 5
            dimension = double(langle(1:3));
            angles = double(langle(4:6))*degree;
        else 
            angles = langle;
            dimension_field = get_field(fieldnames(pN_data), lattice_dim_fields);

            if length(dimension_field) == 3
                dimension = [double(pN_data.(dimension_field{1})(:));
                    double(pN_data.(dimension_field{2})(:));
                    double(pN_data.(dimension_field{3})(:))];
            elseif ~iscell(dimension_field)
                dimension = double(pN_data.(dimension_field)(:));
            else 
                error("The phase dimension was not readable!")
            end 
        end

        disp(dimension)
        disp(angles)

        % get phase names
        phase_name_field = get_field(fieldnames(pN_data), {"Phase_Name", "Name"});
        name = char(pN_data.(phase_name_field));

        % build final cs object
        CS{phase_n + 1} = crystalSymmetry( ...
            csm.pointGroup, ...
            dimension, ...
            angles, ...
            'Mineral', ...
            name);
    end

    % fix phase names
    phaseNames = cellfun(@(x) string(x.mineral), CS(2:end));
    phaseNames = makeDisjoint(phaseNames);
    for p_idx = 2:length(CS)
        CS{p_idx}.mineral = char(phaseNames(p_idx-1));
    end

    % Create opt-----------------------------------------------------------
    opt = struct;
    optList_std  = {'X' 'Y' 'Band_Contrast' 'Band_Slope' 'Bands' 'Mean_Angular_Deviation' 'Pattern_Quality'};
    optNames_std = {'x' 'y' 'bc' 'bs' 'bands' 'MAD' 'quality'};

    % populate opt and skip unkown 
    for jj = 1:length(optNames_std)
        try
            opt.(optNames_std{jj}) = EBSDdata.(optList_std{jj});
        catch
            continue
        end 
    end

    % Build EBSD-----------------------------------------------------------
    ebsd_temp{i} = EBSD(pos, rot, phase, CS, opt);
    
    catch ME 
        warning(['One EBSD dataset could not be loaded! ' ...
            'Either it was never a real dataset and everything is fine. ' ...
            'Or the data could not be loaded correctly!'])
        disp(ME.getReport);
        continue
    end
end

if length(ebsd_temp) > 1
    ebsd = ebsd_temp;
else 
    ebsd = ebsd_temp{1};
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

function [paths] = find_all_data(fname, key, startPath)
    arguments
        fname string
        key string
        startPath string = "/"
    end
    
    try
        root = h5info(fname, startPath);
    catch
        warning('Pfad %s nicht gefunden.', startPath);
        paths = {}; return;
    end
    paths = search_recursive_all(root, key, {});
end

function [paths] = search_recursive_all(node, key, paths)
    % check if parent itself holds the key
    if contains(node.Name, key, 'IgnoreCase', true)
        paths{end+1} = node.Name;
        return; 
    end
    % search subgroups
    if ~isempty(node.Groups)
        for i = 1:length(node.Groups)
            paths = search_recursive_all(node.Groups(i), key, paths);
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