function ebsd = loadEBSD_crc(fname,varargin)


[path,file,ext] = fileparts(fname);

cpr_file = fullfile(path,[file '.cpr']);
crc_file = fullfile(path,[file '.crc']);

try
  if exist(cpr_file,'file') == 2 && exist(crc_file,'file') == 2
    [cs,N,x,y,unitCell] = localReadCPR(cpr_file);
    [phase,q,opts] = localReadCRC(crc_file,N);
    opts.x = x;
    opts.y = y;
  end
  
  ebsd = EBSD(q,cs,symmetry,'phase',phase(:),'unitCell',unitCell,'options',opts);
catch
  interfaceError(fname);
end
end


function [phase,q,opt] = localReadCRC(crc_file,N)

fid = fopen(crc_file,'rb');
data = fread(fid,'*uint8');
fclose(fid);

% make a table
data   = reshape(data,[],N);

phase  = double(data(1,:));
euler1 = double(typecast(reshape(data( 2:5 ,:),[],1),'single'));
euler2 = double(typecast(reshape(data( 6:9 ,:),[],1),'single'));
euler3 = double(typecast(reshape(data(10:13,:),[],1),'single'));

q = euler2quat(euler1,euler2,euler3);

opt.ri         = double(typecast(reshape(data(14:17,:),[],1),'single'));
opt.mad        = double(data(18,:)');
opt.bc         = double(data(19,:)');
opt.bs         = double(data(20,:)');
opt.bands      = double(data(21,:)');
opt.unknown6   = double(data(22,:)');
opt.unknown7   = double(data(23,:)');
opt.unknown8   = double(data(24,:)');
opt.unknown9   = double(data(25,:)'); % indexed or not?

% if there are more columns. read float
for k=26:4:size(data,1)
  
  opt.(['add' num2str((k-22)/4)]) = ...
    typecast(reshape(data(k:k+3,:),[],1),'single');
  
end

end


function [cs,N,x,y,unitCell] = localReadCPR(fname)

fid = fopen(fname);
text = fread(fid,1024*1024,'*char')';
fclose(fid);

p = localParseCPRContent(text);

job = strcmp({p.title},'job');
if any(job)
  job = p(job).contents;
  [N,x,y,unitCell] = localJob2XY(job);
end

phases = strncmp({p.title},'phases',6);
if any(phases)
  phases = p(phases).contents;
  
  if isfield(phases,'count')
    phasecount = phases.count;
  else
    phasecount = [];
  end
end

for k=0:phasecount
  phasek = strncmp({p.title},['phase' num2str(k)] ,6);
  
  if any(phasek)
    phase = p(phasek).contents;
    cs{k+1} = localPhase2CS(phase);
  else
    %     cs{k+1} = symmetry;
    cs{k+1} = 'not Indexed';
  end
end

end


function cpr = localParseCPRContent(text)

lineBreaks = [0 regexp(text,char(10))];

count = 0;
cpr = struct;
for k=1:numel(lineBreaks)-1
  line = text(lineBreaks(k)+1:lineBreaks(k+1)-1);
  
  if strncmp(line,'[',1)
    count = count+1;
    cpr(count).title = lower(line(regexp(line,'[\w*]')));
    cpr(count).contents = struct;
  else
    [name,value] = strtok(line,'=');
    value = deblank(value(2:end));
    
    name = regexprep(name,' ','');
    
    numval = sscanf(value,'%f');
    if ~isempty(numval)
      cpr(count).contents.(lower(name)) = numval;
    else
      cpr(count).contents.(lower(name)) = value;
    end
  end
  
end

end


function [N,x,y,unitCell] = localJob2XY(job)

if isfield(job,'left') && isfield(job,'top')
  xshift = job.left; yshift = job.top; %?? -------------not sure what it means
else
  xshift = 0; yshift = 0;
end

if isfield(job,'xcells') && isfield(job,'ycells')
  xsize = job.xcells; ysize = job.ycells;
  N = xsize*ysize;
else
  xsize = []; ysize = [];
  N = 0;
end

if isfield(job,'griddistx') && isfield(job,'griddistx')
  xstep = job.griddistx; ystep = job.griddistx;
else
  xstep = 1; ystep = 1;
end

if ~isempty(xsize) && ~isempty(ysize);
  [x,y] = meshgrid((0:ysize-1)*ystep-yshift,(0:xsize-1)*xstep-xshift);
  x = x(:); y = y(:);
  unitCell = [ ...
    ystep/2  xstep/2
    ystep/2 -xstep/2
    -ystep/2 -xstep/2
    -ystep/2 xstep/2];
  %   unitCell = calcUnitCell([x y])
else
  x = []; y = []; unitCell = [];
end
end


function cs = localPhase2CS(phase)

if isfield(phase,'structurename')
  mineral = phase.structurename;
else
  mineral = ['phase' num2str(k)];
end

if isfield(phase,'spacegroup')
  group = phase.spacegroup;
  
  list = {...
    1,      '1';
    2,     '-1';
    5,      '2';
    9,      'm';
    15,   '2/m';
    24,   '222';
    46,   'mm2';
    74,   'mmm';
    80,     '4';
    82,    '-4';
    88,   '4/m';
    98,   '422';
    110,'4/mmm';
    122, '-42m';
    142,'4/mmm';
    146,    '3';
    148,   '-3';
    155,   '32';
    161,   '3m';
    167,  '-3m';
    173,    '6';
    174,   '-6';
    176,  '6/m';
    182,  '622';
    186,  '6mm';
    190, '-6m2';
    194,'6/mmm';
    199,   '23';
    206,  'm-3';
    214,  '432';
    220, '-43m';
    230, 'm-3m';};
  
  ndx = nnz([list{:,1}] < group);
  group = list{ndx+1,2};
  
elseif isfield(phase,'lauegroup')
  group = phase.lauegroup;
end

if isfield(phase,'a') && ...
    isfield(phase,'b') && ...
    isfield(phase,'c')
  axes = [phase.a phase.b phase.c];
else
  axes = [1 1 1];
end

if isfield(phase,'alpha') && ...
    isfield(phase,'beta') && ...
    isfield(phase,'gamma')
  angles = [phase.alpha phase.beta phase.gamma]*degree;
else
  angles = [pi/2 pi/2 pi/2];
end

cs = symmetry(group,axes,angles,'mineral',mineral);
end





