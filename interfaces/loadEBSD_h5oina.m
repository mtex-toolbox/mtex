function ebsd = loadEBSD_h5oina(fname,varargin)
% read HKL *.h5oina hdf5 file
% documented here: https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md
% note that Matlab < R2021b does not handle hdf5 v1.10 and one needs to use hdf5format_convert
% (https://github.com/HDFGroup/hdf5) on the input file to prevent Matlab from fatally crashing

% TODO
% 1) Test if EBSDheader.Specimen_Orientation_Euler does what it's supposed
%    to do -> see below
% 2) find a solution if multiple ebsd datasets are contained, export to a
%    cell?
% 3) decide what header data to use and how to display it? Fix display for
% the header to be shown correctly (bc. ebsd.opt.Header sort of works)

all = h5info(fname);

% task: find all groups called EBSD, therein header and PHASE
EBSD_index = {};
EDS_index = {};
n = 1;
m=1;
%search for EBSD data
for i = 1:length(all.Groups) % map site on sample
    if ~isempty(all.Groups(i).Groups) % data on map site ('EBSD, EDS, Electron iamge etc)
        for j=1:length(all.Groups(i).Groups)
            if contains(all.Groups(i).Groups(j).Name,'EBSD')
                EBSD_index{n} = [i j];
                n = n+1;
            end
            if contains(all.Groups(i).Groups(j).Name,'EDS')
                EDS_index{m} = [i j];
                m = m+1;
            end
            
        end
        
    end
end

if length(EBSD_index) > 1
    disp('more than 1 EBSD dataset in the file, output will be a cell')
end
for k = 1 :length(EBSD_index) % TODO: find a good way to write out multiple datasets
    %EBSD dataset
    EBSD_data = all.Groups(EBSD_index{k}(1)).Groups(EBSD_index{k}(2)).Groups(1);
    
    %EBSD header
    EBSD_header = all.Groups(EBSD_index{k}(1)).Groups(EBSD_index{k}(2)).Groups(2);
    
    
    if ~isempty(EDS_index) & EDS_index{k}(1) == EBSD_index{k}(1)
        
        % EDS times and coordiantes - not used for now
        % eds_tc = all.Groups(EDS_index{k}(1)).Groups(EDS_index{k}(2)).Groups(1)
        
        % EDS header
        EDS_header = all.Groups(EDS_index{k}(1)).Groups(EDS_index{k}(2)).Groups(2);
        
        % EDS data
        EDS_data= all.Groups(EDS_index{k}(1)).Groups(EDS_index{k}(2)).Groups(1).Groups;
        
    end
    
    
    % read all EBSD data
    EBSDdata = struct;
    for thing = 1:length(EBSD_data.Datasets)
        sane_name = regexprep(EBSD_data.Datasets(thing).Name,' |-|,|:|%|~|#','_');
        EBSDdata.(sane_name)=double(h5read(fname,[EBSD_data.Name '/' EBSD_data.Datasets(thing).Name]));
    end
    
    %read EBSD header
    EBSDheader = struct;
    for thing = 1:length(EBSD_header.Datasets)
        sane_name = regexprep(EBSD_header.Datasets(thing).Name,' |-|,|:|%|~|#','_');
        content = h5read(fname,[EBSD_header.Name '/' EBSD_header.Datasets(thing).Name]);
        if any(size(content) ~=1) & isnumeric(content)
            content = reshape(content,1,[]);
        end
        EBSDheader.(sane_name) = content;
    end
    
    if ~isempty(EDS_index) & EDS_index{k}(1) == EBSD_index{k}(1)
        %read EDS data
        EDSdata = struct;
        for thing = 1:length(EDS_data.Datasets)
            sane_name = regexprep(EDS_data.Datasets(thing).Name,' |-|,|:|%|~|#','_');
            EDSdata.(sane_name)=double(h5read(fname,[EDS_data.Name '/' EDS_data.Datasets(thing).Name]));
        end
        %read EDS header
        EDSheader = struct;
        for thing = 1:length(EDS_header.Datasets)
            sane_name = regexprep(EDS_header.Datasets(thing).Name,' |-|,|:|%|~|#','_');
            content = h5read(fname,[EDS_header.Name '/' EDS_header.Datasets(thing).Name]);
            if any(size(content) ~=1) & isnumeric(content)
                content = reshape(content,1,[]);
            end
            EDSheader.(sane_name) = content;
        end
        
    end
    
    EBSDphases = struct;
    phases = all.Groups(EBSD_index{k}(1)).Groups(EBSD_index{k}(2)).Groups(2).Groups(1);
    %   ----------------
    
    CS{1}='notIndexed';
    for phaseN = 1:length(phases.Groups)
        pN = ['phase_' num2str(phaseN)];
        EBSDphases.(pN)= struct;
        for j = 1:length(phases.Groups(phaseN).Datasets)
            sane_name = regexprep(phases.Groups(phaseN).Datasets(j).Name,' |-|,|:|%|~|#','_');
            content = h5read(fname,[phases.Groups(phaseN).Name '/' phases.Groups(phaseN).Datasets(j).Name]);
            % format uses an Id for laue groups we do not seem to have
            if strcmpi(sane_name,'Laue_Group')
              content = phases.Groups(phaseN).Datasets(j).Attributes.Value;
            end
            EBSDphases.(pN).(sane_name) = content;
        end
        
        % the angle comes in single precision. make sure something
        % sufficiently close to 90 resp. 120 does not end up with
        % rounding errors instead of using the 'force' option
        
        langle = double(EBSDphases.(pN).Lattice_Angles');
        if ~isempty(EBSDphases.(pN).Space_Group)
            csm = crystalSymmetry('SpaceId',EBSDphases.(pN).Space_Group);
        else
            csm = crystalSymmetry(EBSDphases.(pN).Laue_Group);  
        end
        if strcmp(csm.lattice,'trigonal') | strcmp(csm.lattice,'hexagonal')
            langle(isnull(langle-2/3*pi,1e-7))=2/3*pi;
        else
            langle(isnull(langle-pi/2,1e-7))=pi/2;
        end
        
        CS{phaseN} = crystalSymmetry(csm.pointGroup, ...
            double(EBSDphases.(pN).Lattice_Dimensions'),...
            langle,...
            'Mineral',char(EBSDphases.(pN).Phase_Name));
        %             'X||a*','Y||b', 'Z||C');
    end
    
    
    % write out first EBSD dataset
    % EBSDheader.Specimen_Orientation_Euler: this should be the convention to map
    % CS1 (sample surface) into CS0 (sample primary),
    % CS2 into CS1 should be absolute orientation
    % TODO! make sure those rotations are correctly applied, possibly
    % EBSDheader.Specimen_Orientation_Euler
    
    rc = rotation.byEuler(double(EBSDheader.Specimen_Orientation_Euler*degree)); % what definition? Bunge?
    
    % set up EBSD data
    rot = rc*rotation.byEuler(EBSDdata.Euler');
    phase = EBSDdata.Phase;
    opt=struct;
    opt.x=EBSDdata.X;
    opt.y=EBSDdata.Y;
    opt.bc = EBSDdata.Band_Contrast;
    opt.bs = EBSDdata.Band_Slope;
    opt.bands = EBSDdata.Bands;
    opt.MAD = EBSDdata.Mean_Angular_Deviation;
    opt.quality = EBSDdata.Pattern_Quality;
    
    % if available, add EDS data
    if exist('EDSdata','var')
        eds_names = fieldnames(EDSdata);
        for j =1 :length(eds_names)
        opt.(eds_names{j}) = EDSdata.(eds_names{j});
        end
    end
        
    ebsdtemp = EBSD(rot,phase,CS,opt,'unitCell',calcUnitCell([opt.x,opt.y]));
    ebsdtemp.opt.Header = EBSDheader;
    
    if length(EBSD_index) > 1
        ebsd{k} = ebsdtemp;
    else
        ebsd = ebsdtemp;
    end
    
end



end
