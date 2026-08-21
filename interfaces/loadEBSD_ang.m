function ebsd = loadEBSD_ang(fname,varargin)
% read EDAX *.ang file
%
% Syntax
%
%   ebsd = loadEBSD_ang(fname,'setting',2)
%
% Input
%  fname - file name
%
% Options
%  EulerCorrection -
%  setting         - alignment of the Euler angle and the map reference
%                    frame, 1 to 4, 0 switches the correction off, default
%                    is 2, see
%                    https://mtex-toolbox.github.io/EBSDReferenceFrame.html
%  headerOnly      - return only phase/header metadata, skip reading the data
%
% Flags
%  EDAX     - read the phase column the EDAX way, 1 to N with 0 for not
%             indexed
%  EMSphInx - read the phase column the EMSphInx way, 0 to N-1 with 255 for
%             not indexed
%
% Description
%
% EDAX and EMSphInx write the very same .ang layout but number the phase
% column differently, and neither states which of the two it used. Since
% the values alone can not tell them apart the header is fingerprinted:
% EMSphInx leaves every MaterialName empty, states NumberFamilies 0 and
% lists no reflectors, where OIM always names the material. Pass the EDAX
% or the EMSphInx flag to overrule the guess.
%

assertExtension(fname,'.ang');

% maybe we need to introduce a notIndexed phase
cs = notIndexed;

% read file header - lines staring with #
nh = 1000;
while true
  hl = file2cell(fname,nh);

  % number of header lines
  nh = find(strncmp('#',hl,1),1,'last');
    
  if nh < length(hl) || nh>1e5, break; else, nh = nh + 1000; end
end

% the section describing crystal symmetries 
% starts with # Phase index or # MaterialName

phasePos = find(~cellfun(@isempty, regexp(hl,['# Phase ' '\d'])));
if isempty(phasePos)
  phasePos = strmatch('# MaterialName ',hl)-1;
end
        
minerals = cell(1,length(phasePos));
nFamilies = zeros(1,length(phasePos));

for i = 1:length(phasePos)

  str = hl(phasePos(i):min(phasePos(i)+100,end));

  % load phase number
  phase = readByToken(str,'# Phase',i);

  % load mineral data
  mineral = readByToken(str,'# MaterialName');
  laue = readByToken(str,'# Symmetry');
  pointGroup = readByToken(str,'# PointGroupID');
  lattice = readByToken(str,'# LatticeConstants',[1 1 1 90 90 90]);

  % NaN, not 0, the fingerprint below keys on a phase block stating zero reflectors
  minerals{i} = mineral;
  nFam = readByToken(str,'# NumberFamilies',NaN);
  if isempty(nFam), nFam = NaN; end
  nFamilies(i) = nFam;

  % setup crystal symmetry - the symmetry is stored as a TSL code
  cs(phase+1) = crystalSymmetry(TSL2pointGroup(laue,pointGroup),lattice(1:3)',...
    lattice(4:6)'*degree,'mineral',mineral,'EDAX');

end

% EDAX counts the phases from 1 and keeps 0 for not indexed, EMSphInx counts
% from 0 and flags 255 - EMSphInx fills in no phase description and no # VERSION
isEMSphInx = ~isempty(phasePos) && all(cellfun(@isempty,minerals)) && ...
  all(nFamilies == 0) && isempty(readByToken(hl(1:nh),'# VERSION'));

if check_option(varargin,'EMSphInx'), isEMSphInx = true; end
if check_option(varargin,'EDAX'), isEMSphInx = false; end

% capture all remaining header metadata (phase/symmetry data is excluded,
% it is already captured by cs/CSList above)
header = angHeaderStruct(hl(1:nh),phasePos);

% hint the exact step size from the header, preferred over EBSD's own
% position-based estimate (see EBSD/updateUnitCell)
unitCellHint = {};
if isfield(header,'XSTEP') && isfield(header,'YSTEP')
  xs = header.XSTEP; ys = header.YSTEP;
  if isfield(header,'GRID') && strcmpi(header.GRID,'HexGrid')
    headerCell = vector3d([-xs/2,-xs/2,0,xs/2,xs/2,0],[-ys/3,ys/3,2*ys/3,ys/3,-ys/3,-2*ys/3],0);
  else
    headerCell = vector3d([xs,xs,-xs,-xs]/2,[-ys,ys,ys,-ys]/2,0);
  end
  unitCellHint = {'unitCellHint',headerCell};
end

if check_option(varargin,'headerOnly')
  ebsd = emptyHeaderOnlyEBSD(cs,header,unitCellHint{:});
  return
end

% mineral name to phase number conversion needed?
parts = regexpsplit(hl{end-1},'\s*');
parts(cellfun(@isempty,parts)) = [];
isnum = cellfun(@(x) ~isempty(str2num(x)),parts);
  
if any(~isnum) % if there are any strings
  % try to replace mineral names by numbers
  ReplaceExpr = arrayfun(@(i) {cs(i).mineral,num2str(i)},1:numel(cs),'UniformOutput',false);
  ReplaceExpr = {'ReplaceExpr',ReplaceExpr};
else
  ReplaceExpr = {};
end
  
% read some data
data = txt2mat(fname,'RowRange',[1 10000],ReplaceExpr{:},'infoLevel',0);
    
% we need to guess one of the following conventions
% Euler 1 Euler 2 Euler 3 X Y IQ CI Phase SEM_signal Fit
% Euler 1 Euler 2 Euler 3 X Y IQ CI Fit phase
% Euler 1 Euler 2 Euler 3 X Y IQ CI Fit unknown1 unknown2 phase
% most important is the position of the phase
  
% for future reference:
% the following is taken from a recent .ang file - some new files might
% actually state the version in the header
%
% # NOTES: Start
% # Version 1: phi1, PHI, phi2, x, y, iq (x*=0.1 & y*=0.1)
% # Version 2: phi1, PHI, phi2, x, y, iq, ci
% # Version 3: phi1, PHI, phi2, x, y, iq, ci, phase
% # Version 4: phi1, PHI, phi2, x, y, iq, ci, phase, sem
% # Version 5: phi1, PHI, phi2, x, y, iq, ci, phase, sem, fit
% # Version 6: phi1, PHI, phi2, x, y, iq, ci, phase, sem, fit, PRIAS Bottom Strip, PRIAS Center Square, PRIAS Top Strip, Custom Value
% # Version 7: phi1, PHI, phi2, x, y, iq, ci, phase, sem, fit. PRIAS, Custom, EDS and CMV values included if valid
% # Phase index: 0 for single phase, starting at 1 for multiphase
% # CMV = Correlative Microscopy value
% # EDS = cumulative counts over a specific range of energies
% # SEM = any external detector signal but usually the secondary electron detector signal
% # NOTES: End
%
  
% set up column names
version = readByToken(hl,'# VERSION','x');
switch version
  case {'2', '3', '4', '5', '6'}
    ColumnNames = {'phi1', 'PHI', 'phi2', 'x', 'y', 'IQ', 'CI', 'phase', 'SEM', 'fit', 'PRIAS_Bottom_Strip', 'PRIAS_Center_Square', 'PRIAS_Top_Strip', 'Custom_Value','unknown1' 'unknown2' 'unknown3' 'unknown4' 'unknown5' 'unknown6'};
  case '7'
    ColumnNames = {'phi1' 'PHI' 'phi2' 'x' 'y' 'IQ' 'CI' 'phase' 'SEM' 'fit_PRIAS' 'Custom' 'EDS' 'CM' 'unknown1' 'unknown2' 'unknown3' 'unknown4' 'unknown5' 'unknown6' 'unknown7' 'unknown8' 'unknown9' 'unknown10'};
  otherwise
    ColumnNames = {'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y' 'IQ' 'CI' 'Fit' 'unknown1' 'unknown2' 'unknown3'  'unknown4'  'unknown5' 'unknown6' 'unknown7'};

    % if there was text then it describes the phase
    if any(~isnum)
      phaseCol = find(~isnum,1);
    elseif size(data,2) <= 8
      phaseCol = 8;
    else % take 8 or 9 depending which is more likely
      col8 = unique(data(:,8));
      col9 = unique(data(:,9));
      
      if ~all(ismember(col8,0:length(cs))), col8 = []; end
      if ~all(ismember(col9,0:length(cs))), col9 = []; end
    
      phaseCol = 8 + (length(col9)>length(col8));
    end
        
    switch phaseCol
      case 8
        ColumnNames = {'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit' 'unknown1' 'unknown2' 'unknown3' 'unknown4' 'unknown5' 'unknown6'};
      otherwise
        ColumnNames{phaseCol} = 'Phase';
    end
end
    
ColumnNames = get_option(varargin,'ColumnNames',ColumnNames(1:length(isnum)));

% resolve an EMSphInx phase column below, the generic loader would read the
% numbers as EDAX ones - it lowercases the column name into the property name
iPhase = find(strcmpi(ColumnNames,'Phase'),1);
if isEMSphInx && ~isempty(iPhase), ColumnNames{iPhase} = 'emsphinxphase'; end

% import the data
ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
  'ColumnNames',ColumnNames,varargin{:},'header',nh,ReplaceExpr{:},'keepNaN',unitCellHint{:});

ebsd.opt.header = header;

if isEMSphInx

  ebsd = applyZeroBasedPhases(ebsd,cs);

  % a pixel a ROI mask kept out of the run has orientation, IQ and fit all zero
  ebsd = markUnmeasured(ebsd);

else

  % Explicitly non-indexed phases appear to have 4*pi for all Euler angles
  % which are filtered by loadHelper() already AND ci==-1.
  % Taking phase 0 for non indexed does not really work in the case of single
  % phase ang files; only for multiphase data, notIndexed is 0
  % So here's the attempt to introduce notIndexed to .ang data
  % Set notIndexed (id 0 in multiphase, id -1 in single phase) for ci=-1
  % as well as add empty points (those removed by loadHelper)

  if length(cs)>2
    notIndexedID = 0;
  else
    notIndexedID = -1;
  end

  % phaseMap and CSList have to stay in lockstep, and no phase number may occur twice
  if numel(ebsd.phaseMap) < numel(ebsd.CSList)
    nMissing = numel(ebsd.CSList) - numel(ebsd.phaseMap);
    ebsd.phaseMap = [ebsd.phaseMap(:); max(ebsd.phaseMap) + (1:nMissing).'];
  end
  if ~ismember(notIndexedID,ebsd.phaseMap(2:end))
    ebsd.phaseMap(1) = notIndexedID;
  end
  ebsd(ebsd.rotations.isnan | ebsd.prop.ci<0).phase = ebsd.phaseMap(1);

end

ebsd = applyEulerCorrectionTable(ebsd,'.ang',varargin{:});

% a file does not change how the session plots, but a convention the caller passed does
pC = getClass(varargin,'plottingConvention');
if ~isempty(pC), plottingConvention.default(pC); end

end

function ebsd = applyZeroBasedPhases(ebsd,cs)
% resolve an EMSphInx phase column against the declared phase list
%
% The column was imported as a plain property, so which phase a number
% names is decided here and nowhere else: p counts the declared phases
% from 0, so it is CSList(p+2) - CSList(1) being the notIndexed phase -
% and 255, the largest value the uint8 EMSphInx writes can hold, means the
% pattern could not be indexed. Anything out of range is treated the same
% way rather than silently shifting every phase behind it.

if ~isfield(ebsd.prop,'emsphinxphase'), return; end

p = double(ebsd.prop.emsphinxphase(:));
ebsd.prop = rmfield(ebsd.prop,'emsphinxphase');

% the list starts with the notIndexed phase - unless a file numbered one of
% its phase blocks 0 and overwrote it, then it has to be put back
if cs(1).isIndexed, cs = [notIndexed, reshape(cs,1,[])]; end
nPhases = numel(cs) - 1;

phaseId = p + 2;
phaseId(p < 0 | p >= nPhases) = 1;

ebsd.CSList = cs;
ebsd.phaseMap = [-1;(0:nPhases-1).'];
ebsd.phaseId = phaseId;
ebsd.rotations(phaseId == 1) = NaN;

end

function header = angHeaderStruct(hl,phasePos)
% flatten every non-phase-block header line into a struct
%
% hl       - cell array of header lines (# ...), truncated to the header
% phasePos - line indices of "# Phase N" markers within hl

phaseKeys = {'materialname','formula','info','symmetry','pointgroupid',...
  'latticeconstants','numberfamilies','hklfamilies','elasticconstants',...
  'categories','phase'};

exclude = false(size(hl));

for i = 1:numel(phasePos)
  startIdx = phasePos(i);
  if i < numel(phasePos)
    stopIdx = phasePos(i+1)-1;
  else
    % no explicit end-of-phase-block marker exists; keep consuming lines
    % as long as they belong to one of the known repeatable phase keys
    stopIdx = startIdx;
    for j = startIdx+1:numel(hl)
      tok = regexp(hl{j},'^#\s*([^\s:]+)','tokens','once');
      if isempty(tok) || any(cellfun(@(pk) strncmpi(tok{1},pk,length(pk)),phaseKeys))
        stopIdx = j;
      else
        break;
      end
    end
  end
  exclude(startIdx:stopIdx) = true;
end

keys = {}; values = {};
for i = 1:numel(hl)
  if exclude(i), continue; end
  tok = regexp(hl{i},'^#\s*([^\s:]+)\s*:?\s*(.*)$','tokens','once');
  if isempty(tok), continue; end
  keys{end+1} = tok{1}; %#ok<AGROW>
  values{end+1} = tok{2}; %#ok<AGROW>
end

header = buildHeaderStruct(keys,values);

end

function value = readByToken(cellStr,token,default)

  values = regexp(cellStr,[token '\s*(.*)'],'tokens');
  id = find(~cellfun(@isempty,values),1);
  if ~isempty(id)
    value = strtrim(char(values{id}{1}));
    
    if nargin > 2 && ~isempty(default) && isnumeric(default)
      value = str2num(value);
    end
    
  elseif nargin > 2
    value = default;
  else 
    value = [];
  end
  
end
