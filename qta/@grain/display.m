function display(grains,varargin)
% standart output

disp(' ');
h = doclink('grain_index','grain');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if ~isempty(grains)
  if ~isempty(grains(1).comment)
     h = [h, ' (' grains(1).comment ')'];
  end
end
disp(h)

if ~isempty(grains) 
  %checksums = dec2hex(unique([grains.checksum]));  
  %checksums = strcat('  grain_id', cellstr(checksums) ,',');
  %disp([ checksums{:}]);
  if ~isempty(fields(grains(1).properties))
    disp(['  properties: ',option2str(fields(grains(1).properties))]);
  end
end

[grainPhases,phases,ind] = get(grains,'phase');

matrix = cell(length(phases),5);
for i = 1:length(phases)
  
  % phase
  matrix{i,1} = num2str(phases(i));
  
  % symmetry
  CS = get(grains(ind(i)).orientation,'CS');
  matrix{i,4} = get(CS,'name'); 
  
  % reference frame
  matrix{i,5} = option2str(get(CS,'alignment')); 
  
  % mineral
  if ~isempty(get(CS,'mineral'))
    matrix{i,3} = char(get(CS,'mineral')); 
  end    
  
  % orientations
  matrix{i,2} = nnz(grainPhases == phases(i));
  
end

cprintf(matrix,'-L','  ','-Lc',...
  {'phase' 'grains' 'mineral'  'symmetry' 'crystal reference frame'},...
  '-ic','F');

disp(' ');
