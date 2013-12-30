function  display(grains,varargin)
% standard output

disp(' ');
h = [doclink([class(grains) '_index'], class(grains)) '-' ...
  doclink('GrainSet_index','Set')];

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp([h ' ' docmethods(inputname(1))])

disp(' ')
%disp(char(dynOption(grains)));

%
CS       = grains.ebsd.CS;
phaseMap = grains.ebsd.phaseMap;

matrix = cell(numel(phaseMap),6);

for ip = 1:numel(phaseMap)
  
  % phase
  matrix{ip,1} = num2str(phaseMap(ip)); %#ok<*AGROW>
  
  % grains
  matrix{ip,2} = int2str(nnz(grains.phaseId == ip));
  
  % orientations
  matrix{ip,3} = int2str(nnz(grains.ebsd.phaseId == ip));  
  
  % abort in special cases
  if isempty(CS{ip})
    continue
  elseif ischar(CS{ip})
    matrix{ip,4} = CS{ip};
    continue
  else
    % mineral
    matrix{ip,4} = char(CS{ip}.mineral);
  end
  
  % symmetry
  matrix{ip,5} = CS{ip}.pointGroup;
  
  % reference frame
  matrix{ip,6} = option2str(get(CS{ip},'alignment'));
  
end

if any(grains)
  cprintf(matrix,'-L',' ','-Lc',...
    {'Phase' 'Grains' 'Orientations' 'Mineral'  'Symmetry' 'Crystal reference frame'},...
    '-d','  ','-ic',true);
else
  disp('  GrainSet is empty!')
end

% show properties
disp(' ');
disp(char(dynProp(grains.ebsd.prop)))
disp(' ')
