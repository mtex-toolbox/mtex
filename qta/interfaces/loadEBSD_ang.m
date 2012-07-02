function ebsd = loadEBSD_ang(fname,varargin)

try
  % read file header
  hl = file2cell(fname,1000);
  
  phasePos = strmatch('# Phase',hl);
  
  % phases to be ignored
  ignorePhase = get_option(varargin,'ignorePhase',[]);
  
  try
    for i = 1:length(phasePos)
      pos = phasePos(i);
      
      % load phase number
      phase = sscanf(hl{pos},'# Phase %u');
      
      % may be its to be ignored
      if any(phase==ignorePhase), continue;end
      
      % load mineral data
      mineral = hl{pos+1}(15:end);
      mineral = strtrim(mineral);
      %mineral = sscanf(hl{pos+1},'# MaterialName %s %s %s');
      laue = sscanf(hl{pos+4},'# Symmetry %s');
      lattice = sscanf(hl{pos+5},'# LatticeConstants %f %f %f %f %f %f');
      options = {};
      switch laue
        case {'-3m' '32' '3' '62' '6'}
          options = {'X||a'};
        case '2'
          options = {'X||a*'};
          warning('MTEX:unsupportedSymmetry','symmetry not yet supported!')
        case '1'
          options = {'X||a'};
        case '20'
          laue = {'2'};
          options = {'X||a'};
        otherwise
          if lattice(6) ~= 90
            options = {'X||a'};
          end
      end
      
      cs{phase} = symmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:}); %#ok<AGROW>
    end
    assert(~isempty(cs));
  catch %#ok<CTCH>
    interfaceError(fname);
  end
  
  if check_option(varargin,'check'), return;end
  
  % number of header lines
  nh = find(strmatch('#',hl),1,'last');
  
  % get number of columns
  if isempty(sscanf(hl{nh+1},'%*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %s\n'))
    
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit'},...
      'Columns',1:10,varargin{:},'header',nh);
    
  else
    % replace minearal names by numbers
    replaceExpr = arrayfun(@(i) {get(cs{i},'mineral'),num2str(i)},1:length(cs),'UniformOutput',false);
    
    ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Fit' 'unknown1' 'unknown2' 'phase'},...
      'Columns',1:11,varargin{:},'header',nh,'ReplaceExpr',replaceExpr);
    
  end
catch
  interfaceError(fname);
end
