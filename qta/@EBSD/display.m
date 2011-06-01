function  display(ebsd,varargin)
% standard output

disp(' ');
h = doclink('EBSD_index','EBSD');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if numel(ebsd)>0 && ~isempty(ebsd(1).comment)
  s = ebsd(1).comment;
  if length(s) > 60, s = [s(1:60) '...'];end

  h = [h,' (',s,')'];
end

disp(h)

if numel(ebsd)>0 && ~isempty(fields(ebsd(1).options))
  disp(['  properties: ',option2str(fields(ebsd(1).options))]);
end

for i = 1:length(ebsd)
  
  % phase
  if ~isempty(ebsd(i).phase), matrix{i,1} = num2str(ebsd(i).phase(1)); end%#ok<AGROW>
  
  % symmetry
  CS = get(ebsd(i).orientations,'CS');
  matrix{i,4} = get(CS,'name'); %#ok<AGROW>
  
  % reference frame
  CS = get(ebsd(i).orientations,'CS');
  matrix{i,5} = option2str(get(CS,'alignment')); %#ok<AGROW>
  
  % mineral
  if ~isempty(get(CS,'mineral'))
   matrix{i,3} = char(get(CS,'mineral')); %#ok<AGROW>
  end    
  
  % orientations
  matrix{i,2} = int2str(numel(ebsd(i).orientations)); %#ok<AGROW>
  
end

if numel(ebsd)>0
  cprintf(matrix,'-L','  ','-Lc',...
    {'phase' 'orientations' 'mineral'  'symmetry' 'crystal reference frame'},...
    '-ic','F');
end

disp(' ');
