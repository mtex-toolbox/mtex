function [ebsd] = loadEBSD_h5oina(fname,varargin)
% read HKL *.h5oina hdf5 file
% documented here: https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md
% note that Matlab < R2021b does not handle hdf5 v1.10 and one needs to use hdf5format_convert
% (https://github.com/HDFGroup/hdf5) on the input file to prevent Matlab from fatally crashing
%
% Syntax
%   % import EBSD data in acquisition surface coordinates (CS1)
%   ebsd = loadEBSD_h5oina('ebsdData.h5oina');
%
%   % import EBSD data in sample primary coordinates (CS0)
%   ebsd = loadEBSD_h5oina('ebsdData.h5oina','CS0');
%
% Options
%   CS0 - use sample primary coordinates (default - use acquisition
%   coordinates CS1)
% 
% 
% TODO
% 1) Test if EBSDheader.Specimen_Orientation_Euler does what it's supposed
%    to do -> see below. <-- looks like this is in some datasets stored in
%    the 'Data Processing' header, radians, Bunge convention
% 2) find a solution if multiple ebsd datasets are contained, export to a
%    cell?
% 3) decide what header data to use and how to display it? Fix display for
% the header to be shown correctly (bc. ebsd.opt.Header sort of works)

all = h5info(fname);

% task: find all groups called EBSD, therein header and PHASE
EBSD_index = {};
EDS_index = {};
Image_index = {};
Processing_index = {};
n = 1;
m=1;
p=1;
q=1;
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
            if contains(all.Groups(i).Groups(j).Name,'Electron Image')
                Image_index{p} = [i j];
                p = p+1;
            end

            if contains(all.Groups(i).Groups(j).Name,'Data Processing')
                Processing_index{q} = [i j];
                q = q+1;
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
    
    if ~isempty(Image_index) & Image_index{k}(1) == EBSD_index{k}(1)
        
        % Image header
        Image_header = all.Groups(Image_index{k}(1)).Groups(Image_index{k}(2)).Groups(2);
        
        % Image data
        Image_data= all.Groups(Image_index{k}(1)).Groups(Image_index{k}(2)).Groups(1).Groups;
        
    end
    
    if ~isempty(Processing_index) & Processing_index{k}(1) == EBSD_index{k}(1)
        
        % Processing header
        Processing_header = all.Groups(Processing_index{k}(1)).Groups(Processing_index{k}(2)).Groups(3);
        
        % Processing data
        Processing_data= all.Groups(Processing_index{k}(1)).Groups(Processing_index{k}(2)).Groups(2);
        
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
        % are there multiple datasets?
        allEDS = {EDS_data.Datasets};
        EDSPATH = {EDS_data.Name};
        %read all datsets
        for est=1:length(allEDS)
            for thing = 1:length(allEDS{est})
                sane_name = regexprep(allEDS{est}(thing).Name,{' |-|,|:|%|~|#' char(945) char(946)},{'_' 'a' 'b'});
                EDSdata.(sane_name)=double(h5read(fname,[EDSPATH{est} '/' allEDS{est}(thing).Name]));
            end
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

     if ~isempty(Image_index) & Image_index{k}(1) == EBSD_index{k}(1)
         %read image data
        Imagedata = struct;
        % are there multiple datasets?
        allImage = {Image_data.Datasets}; %TODO - group FSE and SE images better
        ImagePATH = {Image_data.Name};
        %read all datsets
        for est=1:length(allImage)
            for thing = 1:length(allImage{est})
                sane_name = regexprep(allImage{est}(thing).Name,' |-|,|:|%|~|#','_');
                Imagedata.(sane_name)=double(h5read(fname,[ImagePATH{est} '/' allImage{est}(thing).Name]));
            end
        end
        
        %read image header
        Imageheader = struct;
        for thing = 1:length(Image_header.Datasets)
            sane_name = regexprep(Image_header.Datasets(thing).Name,' |-|,|:|%|~|#','_');
            content = h5read(fname,[Image_header.Name '/' Image_header.Datasets(thing).Name]);
            if any(size(content) ~=1) & isnumeric(content)
                content = reshape(content,1,[]);
            end
            Imageheader.(sane_name) = content;
        end

        % try to gridify the images (read axis ij)
        try
            for est=1:length(allImage)
                for thing = 1:length(allImage{est})
                    sane_name = regexprep(allImage{est}(thing).Name,' |-|,|:|%|~|#','_');
                    %assume image is read across rows first
                    Imagedata.(sane_name)=permute(reshape(Imagedata.(sane_name)(:),[Imageheader.X_Cells Imageheader.Y_Cells]),[2 1]);
                end
            end
        catch
        end
     end

     if ~isempty(Processing_index) & Processing_index{k}(1) == EBSD_index{k}(1)
         %read EDS data
         Processingdata = struct;
         % are there multiple datasets?
         allProcessing = {Processing_data.Datasets};
         ProcessingPATH = {Processing_data.Name};
         %read all datsets
         for est=1:length(allProcessing)
             for thing = 1:length(allProcessing{est})
                 sane_name = regexprep(allProcessing{est}(thing).Name,' |-|,|:|%|~|#','_');
                 Processingdata.(sane_name)=double(h5read(fname,[ProcessingPATH{est} '/' allProcessing{est}(thing).Name]));
             end
         end

         %read EDS header
         Processingheader = struct;
         for thing = 1:length(Processing_header.Datasets)
             sane_name = regexprep(Processing_header.Datasets(thing).Name,' |-|,|:|%|~|#','_');
             content = h5read(fname,[Processing_header.Name '/' Processing_header.Datasets(thing).Name]);
             if any(size(content) ~=1) & isnumeric(content)
                 content = reshape(content,1,[]);
             end
             Processingheader.(sane_name) = content;
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
        if ~isempty(EBSDphases.(pN).Space_Group) & EBSDphases.(pN).Space_Group ~= 0
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
    % EBSDheader.Specimen_Orientation_Euler <-- now done
    % This is (sometimes?) contained in the 'Data Processing' header
    if ~isempty(Processing_index) && nnz(Processingheader.Specimen_Orientation_Euler)>0
        % Specimen_Orientation_Euler angles are in radians, Bunge convention
        rc = rotation.byEuler(double(Processingheader.Specimen_Orientation_Euler));
    else
        rc = rotation.byEuler(double(EBSDheader.Specimen_Orientation_Euler));
    end

    % set up EBSD data
    if check_option(varargin,'CS0')
        rot = rc*rotation.byEuler(EBSDdata.Euler'); 
    else
        rot = rotation.byEuler(EBSDdata.Euler'); %don't rotate - keep CS1 (default - acquisition surface0
    end
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

     % if available, add Image data
    if exist('Imagedata','var')
        image_names = fieldnames(Imagedata);
        for j =1 :length(image_names)
        ebsdtemp.opt.Images.(image_names{j}) = Imagedata.(image_names{j});
        end
        ebsdtemp.opt.Images.Header = Imageheader;
    end
    
    if length(EBSD_index) > 1
        ebsd{k} = ebsdtemp;
    else
        ebsd = ebsdtemp;
    end
    
end



end
