function ebsd = loadEBSD_dream3d(fname,varargin)

try
  api = localGetApi(fname);
catch %#ok<CTCH>
  interfaceError(fname);
end

[opts,unitCell] = localGetGrid(api);
[opts,data]     = localGetFields(api,opts);

uphases = unique(data.Phases);
CS = get_option(varargin,'CS',repmat({crystalSymmetry('cubic')},numel(uphases),1));

ebsd = EBSD(data.Rotations,data.Phases,CS,opts,'unitCell', unitCell);


function api = localGetApi(fname)

hInfo = h5info(fname);

dataContainer    = hInfo.Groups;
dataGroups       = dataContainer.Groups;

cellDataGroupNdx = ~cellfun('isempty',strfind({dataGroups.Name},'CELL_DATA'));
cellData         = dataGroups(cellDataGroupNdx);

cellDataSpace    = [cellData.Datasets.Dataspace];
n                = max([cellDataSpace.Size]);

api.readProperty = @(propName) double(h5read(fname,[ dataContainer.Name '/' propName]));
api.readCellData = @(cellName) double(reshape(h5read(fname,[ cellData.Name '/' cellName])',n,[]));
api.fieldNames   = {cellData.Datasets.Name};

api.GoodVoxels   = logical(api.readCellData('GoodVoxels'));


function [opts, unitCell] = localGetGrid(api)

X  = api.readProperty('DIMENSIONS');
dX = api.readProperty('SPACING');
X0 = api.readProperty('ORIGIN');

sX = (dX.*(X-1))+X0;

[y,x,z] = meshgrid(...
  X0(2):dX(2):sX(2),...
  X0(1):dX(1):sX(1),...
  X0(3):dX(3):sX(3));

opts.x = x(api.GoodVoxels)+X0(1);
opts.y = y(api.GoodVoxels)+X0(2);
opts.z = z(api.GoodVoxels)+X0(3);

unitCell =  [ ...
  -dX(1)/2   -dX(2)/2
  -dX(1)/2    dX(2)/2
   dX(1)/2    dX(2)/2
   dX(1)/2   -dX(2)/2
  -dX(1)/2   -dX(3)/2
   dX(1)/2   -dX(3)/2
   dX(1)/2    dX(3)/2
  -dX(1)/2    dX(3)/2
  -dX(2)/2   -dX(3)/2
  -dX(2)/2    dX(3)/2
   dX(2)/2    dX(3)/2
   dX(2)/2   -dX(3)/2];


function [opts,e] = localGetFields(api,opts)

for k=1:numel(api.fieldNames)

  data = api.readCellData(api.fieldNames{k});
  data = data(api.GoodVoxels,:);

  switch api.fieldNames{k}
    case 'EulerAngles'
      e.Rotations = rotation.byEuler(data(:,1),data(:,2),data(:,3),'ZXZ');
    case 'Phases'
      e.Phases = data;
    case {'GoodVoxels','Quats'}
    otherwise
      prop = regexprep(api.fieldNames{k},' ','');
      opts.(prop) = data;
  end

end
