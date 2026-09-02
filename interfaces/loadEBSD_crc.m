function ebsd = loadEBSD_crc(fname,varargin)
% interface for Oxford Channel-5 crc and cpr EBSD data files
% 
%
% Options
%  EulerCorrection -
%  headerOnly - return only phase/header metadata, skip reading the data

assertExtension(fname,'.cpr','.crc');

[path,file] = fileparts(fname);
cprFile = fullfile(path,[file '.cpr']);
crcFile = fullfile(path,[file '.crc']);

cpr = localCPRParser(cprFile);

CS  = get_option(varargin,'CS',getCS(cpr));
param = getJobParam(cpr);

if check_option(varargin,'headerOnly')
  ebsd = emptyHeaderOnlyEBSD(CS,cpr,'unitCell',param.unitCell);
  return
end

loader = localCRCLoader(crcFile,param);
  
rot = loader.getRotations();
pos = vector3d(loader.getColumnData('x'),loader.getColumnData('y'),0);
phases  = loader.getColumnData('phase');
options = loader.getOptions('ignoreColumns',{'phase','x','y'});
  
ebsd = EBSD(pos,rot,phases,CS,options,'unitCell',param.unitCell);
ebsd.opt.header = cpr;

% change reference frame - [Acquisition Surface] is the acquisition surface
% orientation, reported but not applied, see applyEulerCorrectionFixed
acq = [];
if isfield(cpr,'acquisitionsurface') && ...
    all(isfield(cpr.acquisitionsurface,{'euler1','euler2','euler3'}))
  acq = [cpr.acquisitionsurface.euler1, cpr.acquisitionsurface.euler2, ...
    cpr.acquisitionsurface.euler3];
end
ebsd = applyEulerCorrectionFixed(ebsd,'.cpr',rotation.byEuler(pi,0,0),...
  varargin{:},'acquisitionEuler',acq);

% a file does not change how the session plots, but a convention the caller passed does
pC = getClass(varargin,'plottingConvention');
if ~isempty(pC), plottingConvention.default(pC); end

end

% -----------------------------------------------------------------------

function loader = localCRCLoader(crcFile,params)
% reads the binary crc file into a matrix

fid  = fopen(crcFile,'rb');
data = fread(fid,'*uint8');
fclose(fid);

type = params.ColumnType;
if isempty(params.n)
  n = numel(data) / params.m;
else
  n = params.n;
end
data = reshape(data,[],n);          % m × n uint8
ndx  = cumsum([0 type]);

nf = numel(type);
% double, not single - the nfft/nfsft mex interfaces insist on double input
d  = zeros(n, nf + 2*params.cells);

for j = 1:nf
  off = ndx(j);
  if type(j) == 4
    b = data(off+1:off+4, :);            % 4 × n, small temporary
    d(:,j) = typecast(b(:), 'single');   % contiguous column write
  else
    d(:,j) = data(off+1, :);
  end
end

if params.cells % append implicit coordinates 
  d(:,nf+1) = params.x;
  d(:,nf+2) = params.y;  
  params.ColumnNames = [params.ColumnNames 'x','y'];  
end

loader = loadHelper(d,'ColumnNames',params.ColumnNames,'Radians');

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
    cpr.(Title).(field) = coerceNumeric(value);
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
  'm',[],'n',[],... % number of datatyped cols × rows
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

% [Phases] Count may exceed the [PhaseN] sections, so start from notIndexed
CS = repmat(notIndexed,1,cpr.phases.count);
missing = false(1,cpr.phases.count);

% the crystallography a phase section has to state to be usable
required = {'a','b','c','alpha','beta','gamma','structurename'};

for p=1:cpr.phases.count

  sec = ['phase' num2str(p)];
  if ~isfield(cpr,sec) || ~all(isfield(cpr.(sec),required))
    missing(p) = true;
    continue
  end
  phase = cpr.(sec);

  if isfield(phase,'spacegroup') && phase.spacegroup>0
    Laue = {'spaceId',phase.spacegroup};
  elseif ischar(phase.lauegroup)
    Laue = ensurecell(phase.lauegroup);
  else
    Laue = laueGroups;
    Laue = Laue(phase.lauegroup,1);
  end

  CS(p) = crystalSymmetry(Laue{:},...
    [phase.a phase.b phase.c],...
    [phase.alpha phase.beta phase.gamma]*degree,...
    'mineral',phase.structurename);
end

if any(missing)
  mtexWarning('MTEX:cprPhaseMissing',['the cpr file announces %d phases ' ...
    'but does not describe phase %s - pixels of that phase are imported ' ...
    'as notIndexed'],cpr.phases.count,...
    strjoin(arrayfun(@num2str,find(missing),'UniformOutput',false),', '));
end

CS = [notIndexed,CS];

end

