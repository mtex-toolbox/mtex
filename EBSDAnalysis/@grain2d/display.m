function  display(grains,varargin)
% standard output

disp(' ');
h = doclink('grain2d_index','grain2d');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp([h ' ' docmethods(inputname(1))])

disp(' ')
%disp(char(dynOption(grains)));

% generate phase table
matrix = cell(numel(grains.phaseMap),6);

for ip = 1:numel(grains.phaseMap)
  
  % phase
  matrix{ip,1} = num2str(grains.phaseMap(ip)); %#ok<*AGROW>
  
  % grains
  matrix{ip,2} = int2str(nnz(grains.phaseId == ip));
    
  % abort in special cases
  if isempty(grains.CSList{ip})
    continue
  elseif ischar(grains.CSList{ip})
    matrix{ip,3} = grains.CSList{ip};
    continue
  else
    % mineral
    matrix{ip,3} = char(grains.CSList{ip}.mineral);
  end
  
  % symmetry
  matrix{ip,4} = grains.CSList{ip}.pointGroup;
  
  % reference frame
  matrix{ip,5} = option2str(grains.CSList{ip}.alignment);
  
end

% remove empty rows
matrix(histc(full(grains.phaseId),1:numel(grains.phaseMap))==0,:) = [];

if ~isempty(grains)
  cprintf(matrix,'-L',' ','-Lc',...
    {'Phase' 'Grains' 'Mineral'  'Symmetry' 'Crystal reference frame'},...
    '-d','  ','-ic',true);
else
  disp('  no grains here!')
end

% show properties
disp(' ');
disp(char(dynProp(grains.prop)))
disp(' ')
