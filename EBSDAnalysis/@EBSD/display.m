function  display(ebsd,varargin)
% standard output

disp(' ');
h = doclink('EBSD_index','EBSD');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp([h ' ' docmethods(inputname(1))])

% empty ebsd set 
if isempty(ebsd)
  disp('  EBSD is empty!')
  return
end

disp(' ')
% display all other options
disp(char(dynOption(ebsd)));

% ebsd.phaseMap
matrix = cell(numel(ebsd.phaseMap),5);
for ip = 1:numel(ebsd.phaseMap)

  % phase
  matrix{ip,1} = num2str(ebsd.phaseMap(ip)); %#ok<*AGROW>

  % orientations
  matrix{ip,2} = int2str(nnz(ebsd.phaseId == ip));
  
    % mineral
  CS = ebsd.allCS{ip};
  % abort in special cases
  if isempty(CS), 
    continue
  elseif ischar(CS)
    matrix{ip,3} = CS;  
    continue
  else
    matrix{ip,3} = char(CS.mineral);
  end

  % color
  matrix{ip,4} = char(CS.color);
  
  % symmetry
  matrix{ip,5} = CS.spaceGroup;

  % reference frame
  matrix{ip,6} = option2str(CS.alignment);

end


cprintf(matrix,'-L',' ','-Lc',...
  {'Phase' 'Orientations' 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'},...
  '-d','  ','-ic',true);

disp(' ');
disp(char(dynProp(ebsd.prop)));
disp(' ');
