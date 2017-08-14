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
      
      % detect mineral names in orientation table
      ReplaceExpr{i} = {mineral,int2str(i)}; %#ok<AGROW>
    end
    assert(numel(cs)>0);
  catch %#ok<CTCH>
    interfaceError(fname);
  end
  
  if check_option(varargin,'check'), return;end
  
  % number of header lines
  nh = find(strmatch('#',hl),1,'last');
  
  % mineral name to phase number conversion needed?
  if numel(sscanf(hl{end},'%f')) < 11
    varargin = [{'ReplaceExpr',ReplaceExpr},varargin];
  end
     
  % get number of columns
  if isempty(sscanf(hl{nh+1},'%*f %*f %*f %*f %*f %*f %*f %*f %*f %*f\n'))
  
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal'},...
      'Columns',1:9,varargin{:},'header',nh);
    
  elseif isempty(sscanf(hl{nh+1},'%*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %s\n'))
        
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit'},...
      'Columns',1:10,varargin{:},'header',nh);
      
  elseif isempty(sscanf(hl{nh+1},'%*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %s\n'))
      % replace minearal names by numbers
    replaceExpr = arrayfun(@(i) {cs{i}.mineral,num2str(i)},1:numel(cs),'UniformOutput',false);
    
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Fit' 'phase' 'unknown1' 'unknown2' 'unknown3'  'unknown4'  'unknown5' },...
      'Columns',1:14,varargin{:},'header',nh,'ReplaceExpr',replaceExpr);
    
  else
    % replace minearal names by numbers
    replaceExpr = arrayfun(@(i) {cs{i}.mineral,num2str(i)},1:numel(cs),'UniformOutput',false);
    
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Fit' 'unknown1' 'unknown2' 'phase'},...
      'Columns',1:11,varargin{:},'header',nh,'ReplaceExpr',replaceExpr);
    
  end
catch
  interfaceError(fname);
end

% change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  ebsd = rotate(ebsd,rotation('axis',xvector+yvector,'angle',180*degree),'keepEuler');
elseif check_option(varargin,{'convertEuler2SpatialReferenceFrame','wizard'})
  ebsd = rotate(ebsd,rotation('axis',xvector+yvector,'angle',180*degree),'keepXY');
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