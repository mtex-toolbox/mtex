function ebsd = loadEBSD_ang(fname,varargin)
% read TSL *.ang file
%
% Syntax
%   ebsd = loadEBSD_ang(fname,'convertSpatial2EulerReferenceFrame')
%   ebsd = loadEBSD_ang(fname,'convertEuler2SpatialReferenceFrame')
%
% Input
%  fname - file name
%
% Flags
%  convertSpatial2EulerReferenceFrame - change x and y values such that
%  spatial and Euler reference frame coincide, i.e., rotate them by 180
%  degree
%  convertEuler2SpatialReferenceFrame - change the Euler angles such that
%  spatial and Euler reference frame coincide, i.e., rotate them by 180
%  degree

ebsd = EBSD;

try
  assertExtension(fname,'.ang');

  % read file header
  hl = file2cell(fname,2000);
  
  phasePos = strmatch('# Phase ',hl);
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
          laue = {'2'};
          options = {'y||b','z||c'};
        otherwise
          if lattice(6) ~= 90
            options = {'X||a'};
          end
      end
      cs{phase} = crystalSymmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:}); %#ok<AGROW>
      
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
  
catch
  interfaceError(fname);
end

% change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector+yvector,180*degree),'keepEuler');
elseif check_option(varargin,{'convertEuler2SpatialReferenceFrame','wizard'})
  ebsd = rotate(ebsd,rotation.byAxisAngle(xvector+yvector,180*degree),'keepXY');
else
  warning(['.ang files have usualy inconsistent conventions for spatial ' ...
    'coordinates and Euler angles. You may want to use one of the options ' ...
    '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this']);  
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