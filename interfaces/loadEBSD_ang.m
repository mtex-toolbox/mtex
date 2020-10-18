function ebsd = loadEBSD_ang(fname,varargin)
% read EDAX *.ang file
%
% Syntax
%
%   % change x and y values such that spatial and Euler reference frame 
%   % coincide, i.e., rotate them by 180 degree
%   ebsd = loadEBSD_ang(fname,'convertSpatial2EulerReferenceFrame')
%
%   % change the Euler angles such that spatial and Euler reference frame 
%   % coincide, i.e., rotate them by 180 degree
%   ebsd = loadEBSD_ang(fname,'convertEuler2SpatialReferenceFrame')
%
% Input
%  fname - file name
%
% Flags
%  convertSpatial2EulerReferenceFrame - 
%  convertEuler2SpatialReferenceFrame - 
%

ebsd = EBSD;

try
  assertExtension(fname,'.ang');

  %maybe we need to introduce a nonIndexed phase
  cs{1} = 'notIndexed';

  % read file header
  hl = file2cell(fname,2000);
  
  %phasePos = strmatch('# Phase ',hl);
  % some ang files come with a line starting "# Phase index"
  phasePos = find(~cellfun(@isempty, regexp(hl,['# Phase ' '\d'])));
  if isempty(phasePos)
    phasePos = strmatch('# MaterialName ',hl)-1;
  end
        
  try
    for i = 1:length(phasePos)
      pos = phasePos(i);
      
      % load phase number
      phase = readByToken(hl(pos:pos+100),'# Phase',i);
            
      % load mineral data
      mineral = readByToken(hl(pos:pos+100),'# MaterialName');
      laue = readByToken(hl(pos:pos+100),'# Symmetry');
      lattice = readByToken(hl(pos:pos+100),'# LatticeConstants',[1 1 1 90 90 90]);
      
      % setup crytsal symmetry
      options = {};
      switch laue
        case {'-3m' '32' '3' '62' '6'}
          options = {'X||a'};
        case '2'
          options = {'X||a*'};
        case '1'
          options = {'X||a'};
        case '20'
          laue = '2';
          options = {'y||b','z||c'};
        otherwise
          if lattice(6) ~= 90
            options = {'X||a'};
          end
      end
      cs{phase+1} = crystalSymmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:}); %#ok<AGROW>
      
    end
    assert(numel(cs)>0);
  catch %#ok<CTCH>
    interfaceError(fname);
  end
  
  if check_option(varargin,'check'), return;end
  
  % number of header lines
  nh = find(strmatch('#',hl),1,'last');
  
  % mineral name to phase number conversion needed?
  parts = regexpsplit(hl{end-1},'\s*');
  parts(cellfun(@isempty,parts)) = [];
  isnum = cellfun(@(x) ~isempty(str2num(x)),parts);
  
  if any(~isnum) % if there are any strings
    % try to replace minearal names by numbers
    ReplaceExpr = arrayfun(@(i) {cs{i}.mineral,num2str(i)},1:numel(cs),'UniformOutput',false);
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
  
  % set up columnnames
  ColumnNames = {'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Fit' 'unknown1' 'unknown2' 'unknown3'  'unknown4'  'unknown5' 'unknown6' 'unknown7'};
  switch phaseCol
    case 8
      ColumnNames = {'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit' 'unknown1' 'unknown2' 'unknown3' 'unknown4' 'unknown5' 'unknown6'};
    otherwise
      ColumnNames{phaseCol} = 'Phase';     
  end       
  ColumnNames = get_option(varargin,'ColumnNames',ColumnNames(1:length(isnum)));
  
  % import the data
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
    'ColumnNames',ColumnNames,varargin{:},'header',nh,ReplaceExpr{:});
  
  
  % Since explicitly non-indexed phases appear to have 4*pi for all Euler angles
  % which are filtered by loadHelper() already AND ci==-1.
  % Taking phase 0 for non indexed does not really work in the case of single 
  % phase ang files;  in only for multiphase data, notIndexed is 0
  % So here's the attempt to introduce notIndexed to .ang data
  % Set notIndexed (id 0 in multiphase, id -1 in single phase) for ci=-1 
  % as well as add empty points (those removed by loadHelper)
  
  if length(cs)>2;
      notIndexedID = 0;
  else
      notIndexedID = -1;
  end
  ebsd.phaseMap(1) = notIndexedID;
  ebsd(ebsd.prop.ci<0).phase=notIndexedID;
  
  % reconstruct empty points previously removed by loadHelper
  % gridify might be easiest
  ebsd=ebsd.gridify;
  ind_no = isnan(ebsd.rotations);
  ebsd=EBSD(ebsd);
  ebsd(ind_no(:)).phase=notIndexedID;
  
catch
  interfaceError(fname);
end

% change reference frame

rot = [...
  rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
  rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
  rotation.byAxisAngle(xvector,180*degree),...         % setting 3
  rotation.byAxisAngle(yvector,180*degree)];           % setting 4

% get the correction setting
corSettings = {'notSet','setting 1','setting 2','setting 3','setting 4'};
corSetting = get_flag(varargin,corSettings,'notSet');
corSetting = find(strcmpi(corSetting,corSettings))-1;

if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  flag = 'keepEuler';
  opt = 'convertSpatial2EulerReferenceFrame';
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
  flag = 'keepXY';
  opt = 'convertEuler2SpatialReferenceFrame';
else  
  if ~check_option(varargin,'wizard')
    warning(['.ang files have usualy inconsistent conventions for spatial ' ...
      'coordinates and Euler angles. You may want to use one of the options ' ...
      '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this']);
  end  
  return  
end

if corSetting == 0
  warning('%s\n\n ebsd = EBSD.load(fileName,''%s'',''setting 2'')',...
    ['You have choosen to correct your EBSD data for differently aligned '...
    'reference frames for the Euler angles and the map coordinates. '...
    'However, you have not specified which reference system setting has been used on your Edax system . ' ...
    'I''m going to assume "setting 1". '...
    'Be careful, the default setting of EDAX is "setting 2". '...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...    
    'Please make sure you have chosen the correct setting and specify it explicitely using the syntax'],...
    opt)
  corSetting = 1;
end
ebsd = rotate(ebsd,rot(corSetting),flag);

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
