function ebsd = loadEBSD_crc(fname,varargin)
% interface for Oxford Channel-5 crc and cpr EBSD data files
% 

try
  assertExt(fname,{'.cpr','.crc'})
  
  [path,file] = fileparts(fname);
  cprFile = fullfile(path,[file '.cpr']);
  crcFile = fullfile(path,[file '.crc']);
  
  cpr = localCPRParser(cprFile);
  
  CS  = get_option(varargin,'CS',getCS(cpr));
  param = getJobParam(cpr);
  
  if check_option(varargin,'check')
    ebsd = EBSD;
    return
  end

  loader  = localCRCLoader(crcFile,param);
  
  rot       = loader.getRotations();
  pos = vector3d(loader.getColumnData('x'),loader.getColumnData('y'),0);
  phases  = loader.getColumnData('phase');
  options = loader.getOptions('ignoreColumns',{'phase','x','y'});
  
  ebsd = EBSD(pos,rot,phases,CS,options,'unitCell',param.unitCell);
  ebsd.opt.cprInfo = cpr;
catch %#ok<CTCH>
  interfaceError(fname);
end

% change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree),'keepEuler');
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector,180*degree),'keepXY');
elseif ~check_option(varargin,'wizard')
  warning(['.crc and .cpr files have usualy inconsistent conventions for spatial ' ...
    'coordinates and Euler angles. You may want to use one of the options ' ...
    '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this']);
end

end

% -----------------------------------------------------------------------

function loader = localCRCLoader(crcFile,params)
% reads the binary crc file into a matrix

fid = fopen(crcFile,'rb');
data = fread(fid,'*uint8');
fclose(fid);

% make a table
if isempty(params.n)
  n = numel(data)./params.m;
else
  n = params.n;
end

data = reshape(data,[],n);
type = params.ColumnType;
ndx  = cumsum([0 type]);

% type conversion to double
d(type==4,:) = reshape(double(typecast(...
  reshape(data(bsxfun(@plus,ndx(type==4),(1:4)'),:),[],1),'single')),[],n);
d(type~=4,:) = double(data(1+ndx(type~=4),:));

if params.cells
  % append implicite coordinates
  
  d(end+1,:) = params.x;
  d(end+1,:) = params.y;
  
  params.ColumnNames = [params.ColumnNames 'x','y'];
  
end

loader = loadHelper(d.','ColumnNames',params.ColumnNames,'Radians');

end

% ------------------------------------------------------------------------

function cpr = localCPRParser(cprFile)
% read cpr file and generate struct of the form
% cpr.sectionName.prop = value

str = strtrim(file2cell(cprFile));

for k = 1:numel(str)
  
  line = str{k};

  if strncmp(line,'[',1)
    Title = lower(strrep(line(2:end-1),' ',''));
  elseif ~isempty(line)
    [field,value] = strtok(line,'=');
    
    field = lower(strrep(field,' ',''));
    value = deblank(value(2:end));
    numericValue = str2double(value);
    
    if isnan(numericValue)
      cpr.(Title).(field) = value;
    else
      cpr.(Title).(field) = numericValue;
    end
  end
end

end

% ------------------------------------------------------------------------

function param = getJobParam(cpr)
% translate cpr info into MTEX readable properties
% like x,y coordinates, property names ....
    
job = cpr.job;
    
param = struct('cells',false,...
  'unitCell',[],...
  'm',[],'n',[],... % number of datatyped cols x rows
  'x',[],'y',[],...
  'ColumnNames',{{'Phase'}},...
  'ColumnType',1);
    
% cpr
if isfield(job,'xcells') && isfield(job,'ycells')
  % implicit coordinates
  param.cells = true;
  
  % create some coordinates
  [y,x] = meshgrid(0:job.ycells-1,0:job.xcells-1);
  if isfield(job,'griddistx') && isfield(job,'griddisty')
    x = x*job.griddistx;
    y = y*job.griddisty;
    
    param.unitCell = [...
      job.griddistx   job.griddisty;
      -job.griddistx   job.griddisty;
      -job.griddistx  -job.griddisty;
      job.griddistx  -job.griddisty;]/2;
  end
  
  % if isfield(job,'left') && isfield(job,'top')
  %   x = x-job.left, y = y-job.top %?? -------------not sure what it means
  % end
  %
  
  param.n = job.xcells * job.ycells;
  param.x = x(:);
  param.y = y(:);
elseif isfield(job,'noofpoints')
  % explicit coordinates
  param.n = job.noofpoints;
else
  % there are no markup in the cpr so it could be some factory value?
  param.m = 29;
end

% default numbere field position, looks in the cpr like the can switch
% order; unclear why
ColumnNames = {
  'X'                  % 1    4 bytes
  'Y'                  % 2       "
  'phi1'               % 3       "
  'Phi'                % 4       "
  'phi2'               % 5       "
  'MAD'                % 6       "
  'BC'                 % 7    1 byte
  'BS'                 % 8       "
  'Unknown'            % 9       "
  'Bands'              % 10      "
  'Error'              % 11      "
  'ReliabilityIndex'   % 12      "
  };
dataType    = [4*ones(6,1);ones(5,1);4];
    
for k=1:cpr.fields.count
  order = cpr.fields.(['field' num2str(k)]);
  
  if order <= 12
    param.ColumnNames{k+1} = ColumnNames{order};
    param.ColumnType(k+1) = dataType(order);
  else
    param.ColumnNames{k+1} = ['Unknown' num2str(order)];
    param.ColumnType(k+1) = 4;
  end  
end
    
% include eds data if available
if isfield(cpr, 'edxwindows') && cpr.edxwindows.count > 0
  % check for the '[EDX Windows]' field in the *.crc file
  % when the '[EDX Windows]' field exists, an additional check ensures eds data actually exists in the *.crc file
  
  % find which fields in 'param.ColumnNames' contain the search string 'Unknown'
  idx = contains(param.ColumnNames,'Unknown');
  % define a counter
  cnt = 1;
  % loop through the eds columns
  for k = 1:numel(idx)
    if idx(k) && cnt <= cpr.edxwindows.count
      param.ColumnNames{k} = cpr.edxwindows.(['window' num2str(cnt)]); % Renames the unknown columns with EDS window names
      param.ColumnType(k) = 4;
      cnt = cnt + 1;
    end
  end
end

end


% --------------------------------------------------------------------

function CS = getCS(cpr)
    
for p=1:cpr.phases.count
  phase = cpr.(['phase' num2str(p)]);
      
  if isfield(phase,'spacegroup') && phase.spacegroup>0
    Laue = {'spaceId',phase.spacegroup};
  elseif ischar(phase.lauegroup)
    Laue = ensurecell(phase.lauegroup);
  else
    LaueGroups =  {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'};
    Laue = LaueGroups(phase.lauegroup);
  end
      
  CS{p} = crystalSymmetry(Laue{:},...
    [phase.a phase.b phase.c],...
    [phase.alpha phase.beta phase.gamma]*degree,...
    'mineral',phase.structurename); %#ok<AGROW>
end

CS = ['notIndexed',CS];

end

