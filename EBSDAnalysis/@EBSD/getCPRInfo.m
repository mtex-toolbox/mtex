function cprInfo = getCPRInfo(ebsd)

% Initialize the nested structure
cprInfo = struct();

% General
cprInfo.General.Version = '5.0';
cprInfo.General.Date = '';
cprInfo.General.Time = '';
cprInfo.General.Description = 'Exported from MTEX';
cprInfo.General.Author = '[Author]';
cprInfo.General.JobMode = 'RegularGrid';
cprInfo.General.SampleSymmetry = 0;
cprInfo.General.ScanningRotationAngle = 0;
cprInfo.General.ProjectFile = '';
cprInfo.General.Notes = '';
cprInfo.General.ProjectNotes = '';
cprInfo.General.Duration = 'n/a';
cprInfo.General.PerCycle = 'n/a';
cprInfo.General.SampleSymmetry = 1;

% Job
stepSize = calcStepSize(ebsd);
gebsd = gridify(ebsd);

cprInfo.Job.Magnification = [];
cprInfo.Job.kV = [];
cprInfo.Job.TiltAngle = 70;
cprInfo.Job.TiltAxis = 0;
cprInfo.Job.Coverage = round(100*(sum(ebsd.isIndexed)/length(ebsd)),2);
cprInfo.Job.Device = 'None';
cprInfo.Job.Automatic = 'True';
cprInfo.Job.NoOfPoints = length(ebsd);
cprInfo.Job.GridDistX = stepSize;
cprInfo.Job.GridDistY = stepSize;
cprInfo.Job.GridDist = stepSize;
cprInfo.Job.xCells = size(gebsd,1);
cprInfo.Job.yCells = size(gebsd,2);

% SEMFields
cprInfo.SEMFields.DOEuler1 = 0;
cprInfo.SEMFields.DOEuler2 = 0;
cprInfo.SEMFields.DOEuler3 = 0;

% SampleAxisLabels
cprInfo.SampleAxisLabels.LabelX0 = 'X0';
cprInfo.SampleAxisLabels.LabelY0 = 'Y0';
cprInfo.SampleAxisLabels.LabelZ0 = 'Z0';
cprInfo.SampleAxisLabels.LabelX1 = 'X1';
cprInfo.SampleAxisLabels.LabelY1 = 'Y1';
cprInfo.SampleAxisLabels.LabelZ1 = 'Z1';

% Acquisition Surface
cprInfo.AcquisitionSurface.Euler1 = 0;
cprInfo.AcquisitionSurface.Euler2 = 0;
cprInfo.AcquisitionSurface.Euler3 = 0;

% Fields
cprInfo.Fields.Count = 9;
cprInfo.Fields.Field1 = 3;
cprInfo.Fields.Field2 = 4;
cprInfo.Fields.Field3 = 5;
cprInfo.Fields.Field4 = 6;
cprInfo.Fields.Field5 = 7;
cprInfo.Fields.Field6 = 8;
cprInfo.Fields.Field7 = 10;
cprInfo.Fields.Field8 = 11;
cprInfo.Fields.Field9 = 12;

% Phases
cprInfo.Phases.Count = length(ebsd.CSList)-1;

% Phase(s)
list = spaceGroups;
for ii = 2:length(ebsd.CSList)
    
    fieldName = sprintf('Phase%d',ii-1);
    [ro,~] = find(strcmp(list,ebsd.CSList{ii}.pointGroup));
    spaceId = list{ro,1};
    
    cprInfo.(fieldName).StructureName = ebsd.CSList{ii}.mineral;
    cprInfo.(fieldName).Reference = '';
    cprInfo.(fieldName).Enabled = 'True';

    cprInfo.(fieldName).a = ebsd.CSList{ii}.axes.x(1);
    cprInfo.(fieldName).b = ebsd.CSList{ii}.axes.y(2);
    cprInfo.(fieldName).c = ebsd.CSList{ii}.axes.z(3);
    
    cprInfo.(fieldName).alpha = ebsd.CSList{ii}.alpha/degree;
    cprInfo.(fieldName).beta = ebsd.CSList{ii}.beta/degree;
    cprInfo.(fieldName).gamma = ebsd.CSList{ii}.gamma/degree;

%     cprInfo.(fieldName).LaueGroup = symmetry.pointGroups(ebsd.CSList{ii}.id).LaueId;
    cprInfo.(fieldName).LaueGroup = [];
    cprInfo.(fieldName).SpaceGroup = spaceId;
    cprInfo.(fieldName).ID1 = [];
    cprInfo.(fieldName).ID2 = [];
    cprInfo.(fieldName).NumberOfReflectors = [];
    cprInfo.(fieldName).Color = randi([0 255]);
end

% Settings
cprInfo.Settings.Thumbnail = [];
cprInfo.Settings.Settings = [];

% % Display the nested structure
% disp(cprInfo);
end
%%



%% Calculate the ebsd map step size
function stepSize = calcStepSize(inebsd)
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end
end
%%



%% Space groups list
function list = spaceGroups
list = {...
    1,    '1';
    2,    '-1';
    5,    '2';
    9,    'm';
    15,   '2/m';
    24,   '222';
    46,   'mm2';
    74,   'mmm';
    80,   '4';
    82,   '-4';
    88,   '4/m';
    98,   '422';
    110,  '4mm';
    122,  '-42m';
    142,  '4/mmm';
    146,  '3';
    148,  '-3';
    155,  '32';
    161,  '3m';
    167,  '-3m';
    173,  '6';
    174,  '-6';
    176,  '6/m';
    182,  '622';
    186,  '6mm';
    190,  '-6m2';
    194,  '6/mmm';
    199,  '23';
    206,  'm-3';
    214,  '432';
    220,  '-43m';
    230,  'm-3m'};
end
%%