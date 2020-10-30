function ebsd = loadEBSD_h5oina(fname,varargin)
% read HKL *.h5oina hdf5 file
% documented here: https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md

% TODO
% 1) eventually read eds data as well as other useful and usable stuff
% 2) Test if EBSDheader.Specimen_Orientation_Euler does what it's supposed
%    to do -> see below
% 3) find a solution if multiple ebsd datasets are contained, export to a
%    cell?
% 4) decide what header data to use and how to display it? Fix display for
% the header to be shown correctly (bc. ebsd.opt.Header sort of works)

% fname = 'oxin.h5oina'

% get file info
all = h5info(fname);

% all.Groups : file my contain multiple datasets
for i = 1:length(all.Groups)
    
    [data, header] =  all.Groups.Groups(1).Groups.Datasets;
    
    EBSDdata = struct;
    
    % read all data
    for thing = 1:length(data)
        sane_name = strrep(data(thing).Name,' ','_');
        %-----------------------------------------      1    / EBSD   /
        EBSDdata.(sane_name)=double(h5read(fname,[all.Groups.Groups(1).Groups(1).Name '/' data(thing).Name]));
    end
    
    %read header
    EBSDheader = struct;
    for thing = 1:length(header)
        sane_name = strrep(header(thing).Name,' ','_');
        content = h5read(fname,[all.Groups.Groups(1).Groups(2).Name '/' header(thing).Name]);
        if any(size(content) ~=1) & isnumeric(content)
            content = reshape(content,1,[]);
        end
        EBSDheader.(sane_name) = content;
    end
    
    % get the phases
    EBSDphases = struct;
    phases = all.Groups.Groups(1).Groups(2).Groups(1).Groups;
    CS{1}='notIndexed';
    for phaseN = 1:length(phases)
        pN = ['phase_' num2str(phaseN)];
        EBSDphases.(pN)= struct;
        for k = 1:length(phases(phaseN).Datasets)
            sane_name = strrep(phases(phaseN).Datasets(k).Name,' ','_');
            content = h5read(fname,[all.Groups.Groups(1).Groups(2).Groups(1).Groups(phaseN).Name '/' phases(phaseN).Datasets(k).Name]);
            EBSDphases.(pN).(sane_name) = content;
        end
        CS{phaseN+1} = crystalSymmetry('SpaceId',EBSDphases.(pN).Space_Group, ...
            double(EBSDphases.(pN).Lattice_Dimensions'),...
            double(EBSDphases.(pN).Lattice_Angles'),...
            'Mineral',char(EBSDphases.(pN).Phase_Name), ...
            'X||a*','Y||b', 'Z||C');
    end
    
    
    
    % EBSDheader.Specimen_Orientation_Euler: this should be the convention to map
    % CS1 (sample surface) into CS0 (sample primary),
    % CS2 into CS1 should be absolute orientation
    % TODO! make sure those rotations are correctly applied, possibly
    % EBSDheader.Specimen_Orientation_Euler
    rc = rotation.byEuler(EBSDheader.Specimen_Orientation_Euler*degree); % what definition? Bunge?
    
    
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
    ebsd = EBSD(rot,phase,CS,opt,'unitCell',calcUnitCell([opt.x,opt.y]));
    ebsd.opt.Header = EBSDheader;
    
end


end