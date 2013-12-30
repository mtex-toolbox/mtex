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

% show comment
if ~isempty(ebsd.comment)
  disp(['  Comment: ' ebsd.comment(1:end-1)]);  
end

if numel(ebsd)>0 && ~isempty(fields(ebsd.options))
  disp(['  Properties: ',option2str(fields(ebsd.options))]);
end


% ebsd.phaseMap
matrix = cell(numel(ebsd.phaseMap),5);
for ip = 1:numel(ebsd.phaseMap)

  % phase
  matrix{ip,1} = num2str(ebsd.phaseMap(ip)); %#ok<*AGROW>

  % orientations
  matrix{ip,2} = [int2str(nnz(ebsd.phase == ip)) ' (' xnum2str(100*nnz(ebsd.phase == ip)./length(ebsd.phase)) '%)'];
  
    % mineral
  CS = ebsd.CS{ip};
  % abort in special cases
  if isempty(CS), 
    continue
  elseif ischar(CS)
    matrix{ip,3} = CS;  
    continue
  else
    matrix{ip,3} = char(get(CS,'mineral'));
  end

  % color
  matrix{ip,4} = char(get(CS,'color'));
  
  % symmetry
  matrix{ip,5} = get(CS,'name');

  % reference frame
  matrix{ip,6} = option2str(get(CS,'alignment'));

end

if numel(ebsd)>0
  cprintf(matrix,'-L','  ','-Lc',...
    {'Phase' 'Orientations' 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'},...
    '-ic','F');
else
  disp('  EBSD is empty!')
end

disp(' ');

if 0 < numel(ebsd) && numel(ebsd) <= 20
  fn = fields(ebsd.options);
  d = zeros(sum(numel(ebsd)),numel(fn));
  for j = 1:numel(fn)
    if isnumeric(ebsd.options.(fn{j}))
      d(:,j) = vertcat(ebsd.options.(fn{j}));
    elseif isa(ebsd.options.(fn{j}),'quaternion')
      d(:,j) = angle(ebsd.options.(fn{j})) / degree;
    end
  end
  cprintf(d,'-Lc',fn);
end
