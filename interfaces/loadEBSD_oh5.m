function [ebsd] = loadEBSD_oh5(fname,varargin)
% read EBSD data from EDAX OIM oh5 file
% EBSD data file generated from OIM Analysis software
% can include multiple EBSD maps
% modified from loadEBSD_h5oina
%
% Syntax
% Import EBSD data 
%  ebsd = loadEBSD_oh5('ebsdData.oh5');
%
% Flags
%  convertSpatial2EulerReferenceFrame 
%  convertEuler2SpatialReferenceFrame 
%
% Options
%
%
% TODO
% 1) option to import only specific EBSD maps
% 2) import other kinds of data (images, EDS?)

% check file extension before proceeding, avoid mixing up with other hdf5
% formats
assertExtension(fname,'.oh5');
if check_option(varargin,'check')
    ebsd = [];
    return
end

genericNameFix = {{'\W'},{'_'}};

% task: find all groups called EBSD. they may be nested in different
% layers.
locEbsd = locFindH5Groups(fname,'EBSD');

if length(locEbsd) > 1
    ebsd = cell(length(locEbsd),1);
    disp('more than 1 EBSD dataset in the file, output will be a cell')
end

for k = 1 :length(locEbsd) % TODO: find a good way to write out multiple datasets
    % % EBSD dataset
    % EBSD orientations are contained in Group /*/OIM Map*/EBSD/ANG/DATA
    EBSD_data = h5info(fname,[locEbsd(k).Name '/Data']);
    %EBSD header
    EBSD_header = h5info(fname,[locEbsd(k).Name '/Header']);

    % read this EBSD map
    % read all EBSD data
    EBSDdata = struct;
    for thing = 1:length(EBSD_data.Datasets)
        sane_name = regexprep(EBSD_data.Datasets(thing).Name,genericNameFix{:});
        EBSDdata.(sane_name)=double(h5read(fname,[EBSD_data.Name '/' EBSD_data.Datasets(thing).Name]));
    end

    %read EBSD header
    EBSDheader = struct;
    for thing = 1:length(EBSD_header.Datasets)
        sane_name = regexprep(EBSD_header.Datasets(thing).Name,genericNameFix{:});
        content = h5read(fname,[EBSD_header.Name '/' EBSD_header.Datasets(thing).Name]);
        if any(size(content) ~=1) & isnumeric(content)
            content = reshape(content,1,[]);
        end
        EBSDheader.(sane_name) = content;
    end

    % find crystal/cartesian alignment from header
    crys2cart = split(EBSDheader.Cartesian_Alignment,', ');
    xyzAlign = strings(length(crys2cart),3);
    xyzAlign(:,1) = extractBefore(crys2cart," || x");
    xyzAlign(:,2)  = extractBefore(crys2cart," || y");
    xyzAlign(:,3)  = extractBefore(crys2cart," || z");
    % need to adjust the strings so you get a 3*1 string array
    % convert to empty strings so that join works
    % but reset any missing parts to missing to use later on
    xyzAlign(ismissing(xyzAlign))="";
    xyzAlign = join(xyzAlign,"",1);
    xyzAlign(xyzAlign=="")=missing;
    xyzAlignChars = cellstr(["X||","Y||","Z||"] + xyzAlign);
    xyzAlignChars(ismissing(xyzAlignChars)) = [];

    % now set up phases in CSList
    phases = h5info(fname,[EBSD_header.Name '/Phase']);
    %   ----------------

    CS=cell(1,length(phases.Groups)+1);
    CS{1}='notIndexed';
    for phaseN = 1:length(phases.Groups)
        pN = ['phase_' num2str(phaseN)];
        EBSDphases.(pN)= struct;
        for j = 1:length(phases.Groups(phaseN).Datasets)
            sane_name = regexprep(phases.Groups(phaseN).Datasets(j).Name,genericNameFix{:});
            content = h5read(fname,[phases.Groups(phaseN).Name '/' phases.Groups(phaseN).Datasets(j).Name]);
            EBSDphases.(pN).(sane_name) = content;
        end

        ldims = double([EBSDphases.(pN).Lattice_Constant_a,...
            EBSDphases.(pN).Lattice_Constant_b, ...
            EBSDphases.(pN).Lattice_Constant_c]);

        % the angle comes in single precision. make sure something
        % sufficiently close to 90 resp. 120 does not end up with
        % rounding errors instead of using the 'force' option
        langle = double(degree*[EBSDphases.(pN).Lattice_Constant_alpha,...
            EBSDphases.(pN).Lattice_Constant_beta, ...
            EBSDphases.(pN).Lattice_Constant_gamma]);
        % PGsymID is not recognised as point group number in MTEX but
        % SpaceGroupNumber seems to match SpaceId
        % or alternatively Symmetry also matches point group number
        csm = crystalSymmetry('SpaceId', EBSDphases.(pN).SpaceGroupNumber);

        if strcmp(csm.lattice,'trigonal') | strcmp(csm.lattice,'hexagonal')
            langle(isnull(langle-2/3*pi,1e-7))=2/3*pi;
        else
            langle(isnull(langle-pi/2,1e-7))=pi/2;
        end

        CS{phaseN+1} = crystalSymmetry(csm.pointGroup, ...
            ldims,...
            langle,...
            'Mineral',char(EBSDphases.(pN).MaterialName),...
            xyzAlignChars{:});
    end

    % extract phase names
    phaseNames = cellfun(@(x) string(x.mineral),CS(2:end));

    % fix conflicting phase names
    phaseNames = makeDisjoint(phaseNames);

    % write back to CS
    for i = 2:length(CS), CS{i}.mineral = char(phaseNames(i-1)); end

    % write out first EBSD dataset
    rot = rotation.byEuler(EBSDdata.Phi1,EBSDdata.Phi,EBSDdata.Phi2);

    if size(rot,2)>1
        rot = transpose(rot);
    end

    % what data should we read, all or just the standard
    phase = EBSDdata.Phase;
    pos = vector3d(EBSDdata.X_Position,EBSDdata.Y_Position,0);

    opt=struct;
    optList_std  = {'IQ' 'CI' 'SEM_Signal' 'Fit' 'PRIAS_Bottom_Strip', 'PRIAS_Center_Square', 'PRIAS_Top_Strip'};
    optNames_std = {'iq', 'ci', 'sem', 'fit', 'PRIAS_Bottom_Strip', 'PRIAS_Center_Square', 'PRIAS_Top_Strip'};


    optList = fieldnames(EBSDdata); % all names
    %throw out all fields that have already been read in separately
    optList = optList(~strcmp('Phase', optList));
    optList = optList(~strcmp('Phi', optList));
    optList = optList(~strcmp('Phi1', optList));
    optList = optList(~strcmp('Phi2', optList));
    optList = optList(~strcmp('X_Position', optList));
    optList = optList(~strcmp('Y_Position', optList));

    % check if names need replacement
    optNames = optList;
    for jj = 1:length(optNames)
        if any(strcmp(optNames{jj},optList_std))
            optNames{jj} = optNames_std{strcmp(optNames{jj},optList_std)};
        end
    end

    % populate opt
    for jj = 1:length(optNames)
        opt.(optNames{jj}) = EBSDdata.(optList{jj});
    end

    % allow user defined CS, overriding the above
    if check_option(varargin,'CS')
        CS = get_option(varargin,'CS');
    end

    ebsdtemp = EBSD(pos,rot,phase,CS,opt);
    ebsdtemp.opt.Header = EBSDheader;

    %% correct reference frames
    % modified from ang loader

    % change reference frame
    rotCor = [...
        rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
        rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
        rotation.byAxisAngle(xvector,180*degree),...         % setting 3
        rotation.byAxisAngle(yvector,180*degree)];           % setting 4

    % read the correction setting from h5 EBSD header
    corSetting = double(h5read(fname,[EBSD_header.Name '/Coordinate System/ID']));

    if check_option(varargin,'convertSpatial2EulerReferenceFrame')
        flag = 'keepEuler';
        opt = 'convertSpatial2EulerReferenceFrame';
    elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
        flag = 'keepXY';
        opt = 'convertEuler2SpatialReferenceFrame';
    else
        if ~check_option(varargin,'wizard')
            warning(['.oh5 files use inconsistent conventions for spatial ' ...
                'coordinates and Euler angles. I''m defaulting to  ' ...
                '''convertEuler2SpatialReferenceFrame'', i.e. ''keepXY'', to correct this']);
        end
        flag = 'keepXY';
        opt = 'convertEuler2SpatialReferenceFrame';       
    end

    ebsdtemp = rotate(ebsdtemp,rotCor(corSetting),flag);

    % set up how2plot
    switch flag
        case 'keepXY'
            ebsdtemp.how2plot=plottingConvention(-zvector,xvector);
        case 'keepEuler'
            switch corSetting
                case 1
                    ebsdtemp.how2plot=plottingConvention(zvector,yvector);
                case 2
                    ebsdtemp.how2plot=plottingConvention(zvector,-yvector);
                case 3
                    ebsdtemp.how2plot=plottingConvention(zvector,-xvector);
                case 4
                    ebsdtemp.how2plot=plottingConvention(zvector,xvector);
            end
    end


    %build cell if required
    if length(locEbsd) > 1
        ebsd{k} = ebsdtemp;
    else
        ebsd = ebsdtemp;
    end

end


