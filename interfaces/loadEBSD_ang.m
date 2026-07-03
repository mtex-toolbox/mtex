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
%  setting - see https://mtex-toolbox.github.io/EBSDReferenceFrame.html
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
        
for i = 1:length(phasePos)
      
  str = hl(phasePos(i):min(phasePos(i)+100,end));
            
  % load phase number
  phase = readByToken(str,'# Phase',i);
            
  % load mineral data
  mineral = readByToken(str,'# MaterialName');
  laue = readByToken(str,'# Symmetry');
  lattice = readByToken(str,'# LatticeConstants',[1 1 1 90 90 90]);
  
  % setup crystal symmetry
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
  cs(phase+1) = crystalSymmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:});
  
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
  
% import the data
ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
  'ColumnNames',ColumnNames,varargin{:},'header',nh,ReplaceExpr{:},'keepNaN');
  
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
ebsd.phaseMap(1) = notIndexedID;
ebsd(ebsd.rotations.isnan | ebsd.prop.ci<0).phase = notIndexedID;

if check_option(varargin,'wizard')
  corSetting = 2; 
else
  corSetting = 0; 
end
corSetting = get_option(varargin,'setting',corSetting);

if corSetting > 0 || check_option(varargin,'EulerCorrection')

  % change reference frame
  rotCorrection = [rotation.id,...
    rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
    rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
    rotation.byAxisAngle(xvector,180*degree),...         % setting 3
    rotation.byAxisAngle(yvector,180*degree)];           % setting 4

  rot = get_option(varargin,'EulerCorrection',rotCorrection(corSetting+1));

  % correct rotations
  ebsd.EulerCorrection = rot;
  
else
  
  fprintf(2,wraptext(['\nWarning: .ang files usually come with different coordinate systems for the Euler angles ' ...
    'and the spatial coordinates. The relative alignment of these coordinate ' ...
    'systems files can be specified when exporting the data from your EBSD maschine ' ...
    'and are labeled as setting 1 to setting 4. Please specifiy this setting ' ...
    'when importing the data using the syntax\n\n' ...
    'ebsd = EBSD.load(fileName,''setting'', 2)' ...
    '\n\n' ...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    '\n']))

end

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
