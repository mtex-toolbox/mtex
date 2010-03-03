function ebsd = loadEBSD_ang(fname,varargin)

% read file header
hl = file2cell(fname,1000);

phasePos = strmatch('# Phase',hl);

try
  for i = 1:length(phasePos)
    pos = phasePos(i);
    phase = sscanf(hl{pos},'# Phase %u');
    mineral = sscanf(hl{pos+1},'# MaterialName %s %s');
    laue = sscanf(hl{pos+4},'# Symmetry %s');
    lattice = sscanf(hl{pos+5},'# LatticeConstants %f %f %f %f %f %f');
    options = {};
    switch laue
      %case {'-3m' '3n' '3' '2' '62' '6'}
      %  options = {'a||y'};
      case '2'
        options = {'a||x'};
        warning('MTEX:unsupportedSymmetry','symmetry not yet supported!')
      case '20'
        laue = '2';
      otherwise
        if lattice(6) ~= 90
          options = {'a||x'};
        end
    end
    
    cs{phase} = symmetry(laue,lattice(1:3)',lattice(4:6)'*degree,'mineral',mineral,options{:}); %#ok<AGROW>
  end
  assert(~isempty(cs));
catch %#ok<CTCH>
  error('MTEX:wrongInterface','Interface ang does not fit file format!');
end

if check_option(varargin,'check'), return;end

%number of header lines
nh = find(strmatch('#',hl),1,'last');

ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','radiant',...
  'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit'},...
  'Columns',1:10,varargin{:},'header',nh);
